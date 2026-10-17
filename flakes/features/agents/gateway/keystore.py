"""Key store for llm-gateway: per-client bearer keys, each with a model
allow-list and a lifetime budget in USD, in one SQLite table (DEC-051).
Stdlib only, so the CLI and its tests run on a plain Python.

Every function takes the database path first and opens it per call. A key is
returned once by `issue` and never stored: the table holds its sha256 hex.
Errors and warnings name the alias, never the key or its hash (POL-001).

Aliases are unique for the life of the table, and revoking keeps the row, so
a revoked alias cannot be issued again: rotate a client's key by issuing a
new alias, then revoking the old one.
"""

import hashlib
import json
import logging
import math
import secrets
import sqlite3
from contextlib import closing, contextmanager
from datetime import datetime, timezone

log = logging.getLogger("llm-gateway.keystore")

SCHEMA = """
create table if not exists keys(
  hash        text primary key,
  alias       text not null unique,
  models      text not null,
  budget_usd  real not null check (budget_usd >= 0),
  spent_usd   real not null default 0 check (spent_usd >= 0),
  created     text not null,
  revoked_at  text
)
"""


class KeyStoreError(Exception):
    """A refused admin operation; the message names the alias."""


class Refused(KeyStoreError):
    """`authenticate` refused the key; the message says why."""


def usd(value):
    """The one parser for money: a finite, non-negative amount as a float.
    NaN would make `spent >= budget` never true, so it is refused with the
    infinities, negatives, non-numbers, bools and None."""
    numeric = isinstance(value, (int, float, str)) and not isinstance(value, bool)
    try:
        amount = float(value) if numeric else math.nan
    except ValueError:
        amount = math.nan
    if not math.isfinite(amount) or amount < 0:
        raise ValueError(f"not a finite, non-negative amount in USD: {value!r}")
    return amount


def key_hash(key):
    return hashlib.sha256(key.encode()).hexdigest()


@contextmanager
def transaction(db):
    """One connection, one transaction: committed on success, rolled back on
    error, closed either way. Creates the table on first use."""
    with closing(sqlite3.connect(db)) as conn:
        conn.row_factory = sqlite3.Row
        conn.execute("pragma journal_mode=wal")
        with conn:
            conn.execute(SCHEMA)
            yield conn


def issue(db, alias, models, budget):
    """Store a new key for `alias` and return it. The only time it exists in
    clear outside the client."""
    models = list(models)
    if not models:
        raise KeyStoreError(f"{alias}: no models")
    budget = usd(budget)
    # sk-: LiteLLM hashes a key with it, and only then, wherever it logs or
    # reports one, as on its auth-failure path (RV-026 F-3).
    key = "sk-" + secrets.token_urlsafe(32)
    try:
        with transaction(db) as conn:
            conn.execute(
                "insert into keys(hash, alias, models, budget_usd, created) values (?, ?, ?, ?, ?)",
                (key_hash(key), alias, json.dumps(models), budget, _now()),
            )
    except sqlite3.IntegrityError:
        raise KeyStoreError(
            f"{alias}: alias already issued (a revoked alias stays taken; use a new one)"
        ) from None
    return key


def authenticate(db, key):
    """The key's row, if it is known, live and under budget; else `Refused`."""
    with transaction(db) as conn:
        found = conn.execute(
            "select * from keys where hash = ?", (key_hash(key),)
        ).fetchone()
    if found is None:
        raise Refused("unknown key")
    row = _row(found)
    if row["revoked_at"] is not None:
        raise Refused(f"{row['alias']}: revoked")
    if row["spent_usd"] >= row["budget_usd"]:
        raise Refused(f"{row['alias']}: budget exhausted")
    return row


def allows_model(row, model):
    return model in row["models"]


def record_spend(db, digest, cost):
    """Add `cost` to the spend of the key with hash `digest`. A cost `usd`
    refuses is logged and counted as 0; an unknown hash is logged and ignored."""
    with transaction(db) as conn:
        found = conn.execute(
            "select alias from keys where hash = ?", (digest,)
        ).fetchone()
        if found is None:
            log.warning("spend for an unknown key not recorded")
            return
        try:
            amount = usd(cost)
        except ValueError:
            log.warning("%s: unusable cost %r counted as 0", found["alias"], cost)
            return
        conn.execute(
            "update keys set spent_usd = spent_usd + ? where hash = ?", (amount, digest)
        )


def revoke(db, alias):
    """Mark the key revoked; the row and its spend stay. Idempotent."""
    _update(db, alias, "revoked_at = coalesce(revoked_at, ?)", _now())


def set_budget(db, alias, budget):
    _update(db, alias, "budget_usd = ?", usd(budget))


def set_models(db, alias, models):
    """Replace a live key's model allow-list; the key itself is unchanged and
    the new list applies on its next request. A revoked key stays dead."""
    models = list(models)
    if not models:
        raise KeyStoreError(f"{alias}: no models")
    _update(db, alias, "models = ?", json.dumps(models), live=True)


def reset_spend(db, alias):
    _update(db, alias, "spent_usd = ?", 0)


def rows(db):
    """Every key's row, oldest first, without its hash."""
    with transaction(db) as conn:
        found = conn.execute("select * from keys order by created, alias").fetchall()
    return [{k: v for k, v in _row(r).items() if k != "hash"} for r in found]


def _update(db, alias, assignment, value, live=False):
    """Set `assignment` on the alias's row. With `live`, a revoked key is
    refused, decided in the same transaction as the update."""
    guard = " and revoked_at is null" if live else ""
    with transaction(db) as conn:
        changed = conn.execute(
            f"update keys set {assignment} where alias = ?{guard}", (value, alias)
        ).rowcount
        exists = (
            changed
            or conn.execute("select 1 from keys where alias = ?", (alias,)).fetchone()
        )
    if not exists:
        raise KeyStoreError(f"{alias}: no such key")
    if not changed:
        raise KeyStoreError(f"{alias}: revoked")


def _row(found):
    row = dict(found)
    row["models"] = json.loads(row["models"])
    return row


def _now():
    return datetime.now(timezone.utc).isoformat(timespec="seconds")

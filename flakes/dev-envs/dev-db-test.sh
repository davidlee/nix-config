#!/usr/bin/env bash
# Behaviour of dev-db, on a cluster of its own. Needs dev-db and a postgresql on PATH.
set -euo pipefail

DEV_DB_ROOT="$(mktemp -d)/db"
export DEV_DB_ROOT DEV_DB_NAME=probe-db
failures=0

trap 'dev-db down >/dev/null 2>&1 || true; rm -rf "$DEV_DB_ROOT"' EXIT

sql() { dev-db psql --tuples-only --no-align --command "$1"; }

# check <description> <command...>   — must succeed
check() {
  local desc="$1"
  shift
  if "$@" >/dev/null 2>&1; then printf 'ok   %s\n' "$desc"; else
    printf 'FAIL %s\n' "$desc"
    failures=$((failures + 1))
  fi
}

# refute <description> <command...>  — must fail
refute() {
  local desc="$1"
  shift
  if "$@" >/dev/null 2>&1; then
    printf 'FAIL %s\n' "$desc"
    failures=$((failures + 1))
  else printf 'ok   %s\n' "$desc"; fi
}

# returns <description> <sql> <expected>
returns() {
  local desc="$1" query="$2" expected="$3" actual
  actual=$(sql "$query") || actual="<error>"
  if [ "$actual" = "$expected" ]; then printf 'ok   %s\n' "$desc"; else
    printf 'FAIL %s (got %q, want %q)\n' "$desc" "$actual" "$expected"
    failures=$((failures + 1))
  fi
}

# sqlx refuses `postgresql://user@/db` (EmptyHost): the authority must stay empty.
url_has_empty_authority() { [[ $(dev-db url) == postgresql:///* ]]; }

env_adopts_the_cluster() (
  eval "$(dev-db env)"
  psql --command 'select 1'
)

without_a_name() { env -u DEV_DB_NAME dev-db status; }

crash() {
  kill -9 "$(head -1 "$DEV_DB_ROOT/data/postmaster.pid")" 2>/dev/null || true
  sleep 0.3
}

echo "# configuration"
refute "a project must name its database" without_a_name
check "help needs no name" env -u DEV_DB_NAME dev-db help

echo "# from nothing"
refute "status exits non-zero before the first up" dev-db status
check "up starts a cluster" dev-db up
check "up is idempotent" dev-db up
check "status succeeds once up" dev-db status
returns "the database is the configured one" 'select current_database()' "$DEV_DB_NAME"
check "the socket is under the root" test -S "$DEV_DB_ROOT/run/.s.PGSQL.5432"
check "the url connects" psql --dbname "$(dev-db url)" --command 'select 1'
check "the url suits sqlx" url_has_empty_authority
check "env adopts the cluster" env_adopts_the_cluster
returns "nothing listens on tcp" "select current_setting('listen_addresses')" ''
check "ambient PG settings do not redirect it" env PGHOST=/nonexistent PGPORT=1 dev-db status

echo "# across a restart"
check "a table can be created" dev-db psql --command 'create table probe (id int)'
check "and written to" dev-db psql --command 'insert into probe values (7)'
check "down stops the server" dev-db down
refute "status is non-zero while down" dev-db status
check "up restarts it" dev-db up
returns "the data survived the restart" 'select count(*) from probe' 1

echo "# after a crash"
check "the server can be killed outright" crash
refute "it stops answering" dev-db status
check "down copes with the wreckage" dev-db down
check "up recovers from the wreckage" dev-db up
returns "and serves again" 'select 1' 1

echo "# reset"
check "reset succeeds" dev-db reset
refute "the table is gone" dev-db psql --command 'select count(*) from probe'

if [ "$failures" -ne 0 ]; then
  printf '\n%d failure(s)\n' "$failures" >&2
  exit 1
fi
printf '\nall checks passed\n'

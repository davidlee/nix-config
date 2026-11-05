# shellcheck shell=bash
# A project's throwaway PostgreSQL, for development and tests.
#
# The real server, from the project's own tools: one cluster, trust auth, every
# file under one root. The root defaults to /tmp, which a jail keeps private, so
# each jail has its own cluster and it dies with the session. Socket only: jails
# share host loopback, where a port would collide and trust auth would be open
# to every jail (RSK-001). The port only names the socket file.

usage() {
  cat <<'USAGE'
dev-db up|down|status|reset|psql|env|url|log|path

up      start (idempotent), creating the cluster and database if need be
down    stop it
status  report where it is, or exit 1 when down
reset   throw the cluster away and start a fresh one
psql    open a session; extra arguments pass through (e.g. -c 'select 1')
env     shell exports for your own tooling: eval "$(dev-db env)"
url     just the connection URL, for an app's DATABASE_URL
log     follow the server log
path    print the root holding data, socket and log

DEV_DB_NAME names the cluster and its database; a project's justfile sets it.
Overrides: DEV_DB_ROOT, DEV_DB_PORT, DEV_DB_LOCALE.
USAGE
}

say() { printf 'dev-db: %s\n' "$*"; }
die() {
  printf 'dev-db: %s\n' "$*" >&2
  exit 1
}

case "${1:-status}" in
  -h | --help | help)
    usage
    exit 0
    ;;
esac

[ -n "${DEV_DB_NAME:-}" ] || die "DEV_DB_NAME is not set: run this through the project's justfile"

NAME="$DEV_DB_NAME"
ROOT="${DEV_DB_ROOT:-/tmp/$NAME/db}"
PORT="${DEV_DB_PORT:-5432}"
LOCALE="${DEV_DB_LOCALE:-C.UTF-8}" # C.UTF-8: codepoint order, no glibc locale data

DATA="$ROOT/data"
RUN="$ROOT/run"
LOG="$ROOT/postgres.log"

# Every psql/pg_ctl/createdb here — and any process we hand off to — inherits these.
export PGHOST="$RUN" PGPORT="$PORT" PGUSER=postgres PGDATABASE="$NAME"

# No authority part: sqlx refuses `postgresql://user@/db` with EmptyHost.
URL="postgresql:///$NAME?host=$RUN&port=$PORT&user=postgres"

BEGIN_MARK="# >>> dev-db"
END_MARK="# <<< dev-db"

is_up() { pg_isready --quiet; }

require_tools() {
  local tool
  for tool in initdb pg_ctl pg_isready psql createdb; do
    command -v "$tool" >/dev/null || die "$tool is not on PATH: add postgresql to the project's dev-tools"
  done
}

init_cluster() {
  [ -f "$DATA/PG_VERSION" ] && return 0
  mkdir -p "$DATA" "$RUN"
  initdb --pgdata "$DATA" --username postgres \
    --auth-local=trust --auth-host=trust \
    --encoding UTF8 --locale "$LOCALE" --no-instructions >/dev/null
}

# Settings live in the cluster's own config, so a bare `pg_ctl start` works too.
# The block is rewritten on every start, so changing the port or root takes.
configure() {
  local conf="$DATA/postgresql.conf"
  touch "$conf"
  awk -v b="$BEGIN_MARK" -v e="$END_MARK" '
    $0 == b { skip = 1; next }
    $0 == e { skip = 0; next }
    !skip   { print }
  ' "$conf" >"$conf.new"
  cat >>"$conf.new" <<CONF
$BEGIN_MARK
port = $PORT
unix_socket_directories = '$RUN'
listen_addresses = ''
# Nothing here needs to outlive the session, so buy speed instead.
fsync = off
synchronous_commit = off
full_page_writes = off
$END_MARK
CONF
  mv "$conf.new" "$conf"
}

# Clear the wreckage of a server that was killed rather than stopped.
clear_stale() {
  if [ -f "$DATA/postmaster.pid" ]; then
    pg_ctl --pgdata "$DATA" stop --mode immediate >/dev/null 2>&1 || true
  fi
  rm -f "$DATA/postmaster.pid" "$RUN/.s.PGSQL.$PORT" "$RUN/.s.PGSQL.$PORT.lock"
}

ensure_database() {
  local found
  found=$(psql --dbname postgres --tuples-only --no-align \
    --command "select 1 from pg_database where datname = '$NAME'")
  [ "$found" = 1 ] || createdb "$NAME"
}

server_version() { psql --dbname postgres --tuples-only --no-align --command 'show server_version'; }

up() {
  require_tools
  if is_up; then
    say "already up on $RUN (port $PORT)"
    return 0
  fi
  init_cluster
  configure
  mkdir -p "$RUN"
  clear_stale
  pg_ctl --pgdata "$DATA" --log "$LOG" --wait start >/dev/null || {
    tail -20 "$LOG" >&2
    die "failed to start; see $LOG"
  }
  ensure_database
  say "up: $(server_version) socket=$RUN port=$PORT database=$NAME"
}

down() {
  if is_up || [ -f "$DATA/postmaster.pid" ]; then
    # A server that stops answering still holds a pid file; up() clears the rest.
    pg_ctl --pgdata "$DATA" --wait --mode fast stop >/dev/null 2>&1 || true
    say "down"
  else
    say "down (was not running)"
  fi
}

reset() {
  down >/dev/null 2>&1 || true
  rm -rf "$ROOT"
  up
}

status() {
  if ! is_up; then
    say "down ($ROOT)"
    return 1
  fi
  say "up: $(server_version) socket=$RUN port=$PORT database=$NAME"
  say "    data $DATA ($(du -sh "$DATA" | cut -f1))"
  say "    url  $URL"
}

print_env() {
  cat <<ENV
export PGHOST='$RUN'
export PGPORT='$PORT'
export PGUSER='postgres'
export PGDATABASE='$NAME'
export DATABASE_URL='$URL'
ENV
}

case "${1:-status}" in
  up) up ;;
  down) down ;;
  status) status ;;
  reset) reset ;;
  psql)
    shift
    exec psql "$@"
    ;;
  env) print_env ;;
  url) printf '%s\n' "$URL" ;;
  path) printf '%s\n' "$ROOT" ;;
  log) exec tail --follow=name --retry "$LOG" ;;
  *) die "unknown command: $1 (try: dev-db help)" ;;
esac

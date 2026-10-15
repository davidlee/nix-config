# ISS-003: system_override fails on hosts without ~/dev/oubliette

MULTIHOST follow-up, before S8. `system_override` names `~/dev/oubliette`; overrides are fetched eagerly even for unrelated attributes, so `system-*`, `drvs` and `update-local` fail on any host without that checkout. Make overrides per host (e.g. only when the path exists).

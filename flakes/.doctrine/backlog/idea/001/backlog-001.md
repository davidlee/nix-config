# IDE-001: Launcher-managed GC roots with expiry

Follow-on to on-demand launchers: record last launch and keep a GC root until it expires, so recently used apps survive GC. Note `--delete-older-than` concerns profile generations, not time since use.

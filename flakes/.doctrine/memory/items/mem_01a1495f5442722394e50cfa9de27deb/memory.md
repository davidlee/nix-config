A pi custom provider (one defined in `<agent-dir>/models.json`, not a built-in)
behaves differently from a built-in one:

- **`baseUrl` is literal.** Only `apiKey` and header values interpolate
  `$NAME`/`${NAME}` or run `!command` (pi 1.3.0 `provider-composer.js`).
- **No built-in metadata is inherited.** A custom model takes `compat` and
  `thinkingLevelMap` only from its own entry (`modelFromJson`). Behind a proxy
  such as LiteLLM, copy them from pi's built-in entry for the upstream model:
  without DeepSeek's `compat`, `--thinking off` is silently ignored (EVD-003).
- **Credential precedence:** `--api-key` > `auth.json` > `models.json` `apiKey` >
  env. A stored `auth.json` entry for the same provider id wins, so give a
  proxy provider its own name (DEC-058).
- **Empty file ≠ missing file.** Missing → no custom providers; empty → a parse
  warning on every start; `{"providers":{}}` is clean (EVD-004). bwrap creates
  a missing bind target as an empty file.
- **Silent model fallback:** an unresolvable saved default falls back to the
  first model with credentials, possibly an OAuth subscription model
  (`model-resolver.js` ~:397-427).

Re-check after pi version bumps (verified on 0.99.1 runtime, 1.3.0 source).

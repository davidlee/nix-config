Read in `~/.local/src/typesafe-sdk-js` (2026-10-28), what matters for anything
proxying TypeSafe (the LLM gateway, SL-019):
- `compression` defaults to `"zstd"` on runtimes with `zlib.zstdCompress`
  (Node >= 22.15) for bodies of 1024 bytes or more, sent as
  `Content-Encoding: zstd` (`src/compression.ts`). `compression: false` turns
  it off. The gateway decodes zstd (DEC-088).
- Assets go as `multipart/form-data` (`src/assets.ts` `encodeAssets`).
  LiteLLM's decisions route parses JSON only, so SDK image requests fail
  through the gateway (DEC-089); raw JSON `assets[].data_base64` works.
- `models.list()` expects `GET /v1/models` as `{models:[...]}`; LiteLLM
  answers OpenAI's `{data:[...]}` (DEC-089).
- Base URL from `baseURL` or `TYPESAFE_BASE_URL`; key `Authorization: Bearer`.

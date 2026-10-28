Probed on CPython 3.14.8 (`compression.zstd`, PEP 784) for SL-019 PHASE-01; the gateway's route gate relies on each point (`_decoded` in gateway_hooks.py).

- `ZstdDecompressor().decompress(data, max_length=N)` bounds the **output** only. The frame header names its window before any output: an 11-byte frame can ask for 128 MiB. Cap it with `options={DecompressionParameter.window_log_max: K}`; an oversize window raises `ZstdError` ("Frame requires too much memory for decoding").
- A **truncated** frame raises nothing: it returns what it has (possibly 0 bytes) with `eof` false. Check `decoder.eof`.
- **Two frames**: the decoder stops after the first, `eof` true, the rest in `unused_data`. Check `unused_data` to insist on one frame.
- Output past the bound: returns exactly `max_length` bytes, `eof` false. Use `max_length = cap + 1` and test `len > cap` before the eof check, so a bomb reads as too large rather than truncated.
- Garbage raises `ZstdError` ("Unknown frame descriptor").

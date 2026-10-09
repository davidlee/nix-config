# Dictation — notes for later iteration

What is built is in the README's Dictation section. This file records the
measurements behind the current choices, and the options left open.

## Current choices

| choice | value | why |
|---|---|---|
| model | Nemotron 3.5 ASR streaming 0.6B, int8 | punctuation and capitals; faster and more accurate than the English-only Nemotron in the comparison below |
| runtime | sherpa-onnx 1.13.3 (nixpkgs) | CPU int8 exports exist for every chunk size; no torch |
| chunk | 560 ms | fewer errors and less CPU than 320 ms (below); text arrives in ~0.6 s bursts |
| threads | 1 | ~1/7 of one core while speaking; fans stay quiet |
| model lifetime | resident | 1.5 GB RAM idle, no load delay on toggle |
| trigger | hold `=` combo (push-to-talk); F9 toggles | see "Push-to-talk" below |

## Measurements (2026-10-09, Ryzen 9 9950X, CPU only)

RTF (real-time factor) is processing time ÷ audio length; under 1 keeps up.
Clips are LibriSpeech test audio (6.6 s and 17 s).

| model | threads | RTF | notes |
|---|---|---|---|
| 3.5, 320 ms | 1 | 0.24 | |
| 3.5, 320 ms | 2 | 0.15 | |
| 3.5, 320 ms | 4 | 0.14–0.19 | |
| English-only, 160 ms | 4 | 0.27–0.37 | no punctuation; more word errors on the same clips |

- Model load: 0.64 s. RSS: ~1.5 GB.
- Streaming partials never revised earlier text, on the English clip fed in
  100 ms pieces or on the French clip in the real-model test. `edit` still
  backspaces a revision if one appears.
- A wrong language hint garbles badly: French audio with `en` gave
  "Demandez plutôt ce pour". `auto` transcribed it correctly and appended no
  language tag.

### 320 vs 560 ms (3.5, 1 thread, language `en`)

| | 320 ms | 560 ms |
|---|---|---|
| word errors, the two 16 kHz clips | 5 | 3 |
| CPU seconds per audio second | 0.22 | 0.14 |

560 ms got "mortals" and "blessed" right where 320 ms said "morts" and
"blest". (An 8 kHz telephone clip, irrelevant to a USB mic, made it 7 vs 6.) Larger chunks are cheaper as well as better: the per-chunk overhead
is spread over more audio. 560 ms is deployed.

### Last word clipped on stop (fixed)

The encoder emits a chunk only after seeing its right context, so a word in
the final chunk was lost when the stream ended straight after it ("brothel"
for "brothels", "apprehen"). `Transcriber.finish` now feeds 1 s of silence
before `input_finished`; 0.6 s was enough at 560 ms. `dictate-test`'s
`RealModel` cuts a clip at its last loud sample to hold this.

## Push-to-talk: what it took

```
hold  ─> hold-tap decides hold (190 ms) ─> ptt: tap F13 ─> XF86Tools   ─> dictate start
release ─────────────────────────────────> ptt: tap F14 ─> XF86Launch5 ─> dictate stop
```

Five things broke along the way; each is now fixed and commented where it lives.

| symptom | cause | fix |
|---|---|---|
| no F13/F14 at all | ZMK's NKRO report stops at usage 0x67 | `CONFIG_ZMK_HID_KEYBOARD_NKRO_EXTENDED_REPORT=y` (planck, corne; glove80 is 6KRO and fine) |
| F14 missing on most releases | ZMK bug: `behavior_macro_init` never sets the release half's `tap_ms`/`wait_ms`, so F14 was a ~2 ms tap the host often missed (evtest: F13 30 ms, F14 2 ms) | `<&macro_tap_time 30>` after `&macro_pause_for_release` |
| binds never fire | xkb names F13/F14 `XF86Tools`/`XF86Launch5`; umbriel matches keysyms | bind those names |
| daemon killed by a key press | real-time signals terminate by default; one arrived while the model loaded, before handlers existed | install handlers before loading |
| new script, old daemon | home-manager restarts a unit only when the unit changes | `ExecStart` runs the store path of the script |

`wev` cannot see keys umbriel has bound. To see what the keyboard sends,
read the device directly: `evtest /dev/input/by-id/usb-ZMK_Project_Planck_*-event-kbd`.

The idle stop still applies while the key is held: a 10 s pause ends the
session, and pressing again starts a new one. A lost release (only possible
over Bluetooth) is bounded by the same 10 s.

## Options left open

**Chunk size.** Exports exist at 80, 160, 320, 560 and 1120 ms. Smaller
chunks give lower latency at somewhat lower accuracy (and more CPU); 1120 ms
also needs a longer tail pad in `finish`; NVIDIA's FLEURS averages
for transcription-ready languages run 10.38% WER at 80 ms down to 8.84% at
1.12 s. Changing it means swapping the URL and hash in `dictate.nix`:

```sh
nix-prefetch-url --unpack <url>          # base32
nix hash to-sri --type sha256 <base32>   # Lix has no `nix hash convert`
```

**Idle RAM.** Loading on toggle instead would free ~1.5 GB between sessions,
at a 0.64 s start cost. To keep the first words, start `pw-record` first and
feed its buffered audio once the model is ready.

**English-only model.** Third-party benchmarks put it about a point of WER
ahead of 3.5 at every shared chunk size, but it has no punctuation. On our
clips 3.5 did better. Re-test against your own voice before switching.

**Quality checks to do.** Long sessions (cache-aware streaming should hold
indefinitely, but unverified); dictating into terminals vs. GUI apps;
whether `wtype` keeps up with fast bursts.

## Sources

- [Model card](https://huggingface.co/nvidia/nemotron-3.5-asr-streaming-0.6b)
- [sherpa-onnx asr-models release](https://github.com/k2-fsa/sherpa-onnx/releases/tag/asr-models)
- [Softcery: hosting Nemotron streaming on a CPU](https://softcery.com/lab/hosting-nemotron-asr-streaming-on-a-cpu)

# DEC-077: Network-isolated jails reach the gateway through an in-jail forwarder; the gateway is their only network egress

<!-- Knowledge record body — context, detail, links. The structured, queried
     fields live in the sister `record-NNN.toml`; this prose is free-form and is
     never structurally parsed (the storage rule). -->

Amended 2026-10-20 after an informal GPT (gpt-6-sol) review, adjudicated in the SL-015 design run and accepted by the user: readiness from PID + /proc/net/tcp (F-1, F-4); deferred netns guard (F-2, F-5); profile network flag as single source; "direct" network path (F-7). F-3 (supervise socat) rejected: failure is visible.
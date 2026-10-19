# DEC-076: Gateway transport is derived from the jail profile's network; socket reach is one exported option list

<!-- Knowledge record body — context, detail, links. The structured, queried
     fields live in the sister `record-NNN.toml`; this prose is free-form and is
     never structurally parsed (the storage rule). -->

Amended 2026-10-20 after an informal GPT (gpt-6-sol) review, adjudicated in the SL-015 design run and accepted by the user: readiness from PID + /proc/net/tcp (F-1, F-4); deferred netns guard (F-2, F-5); profile network flag as single source; "direct" network path (F-7). F-3 (supervise socat) rejected: failure is visible.


Amended 2026-10-20 at SL-015 reconcile (RV-033 F-3): readiness also requires the LISTEN row's inode to belong to our socat's fds; PHASE-03 VT-3's occupied-port case showed a row alone accepts a foreign listener (mem.fact.linux.proc-net-tcp-listen-readiness).

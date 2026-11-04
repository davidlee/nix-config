# DEC-114: Project env is passthru.devEnv { env; hostEnv; }; env preferences for every project are one host-facts list

<!-- Knowledge record body — context, detail, links. The structured, queried
     fields live in the sister `record-NNN.toml`; this prose is free-form and is
     never structurally parsed (the storage rule). -->

Relation to earlier records: amends DEC-103 (the stub project states one devEnv.env and one devEnv.hostEnv entry, and checks.stub asserts both reach the launcher).



Amended at SL-023 reconcile: `for` also returns `hostOnlyEnv`, applied to host shells only and never to a jail or form (DEC-121). `checkDevEnv` refuses its names as it does the host list's (`hostNames`, RV-047 F-2). The dispatch jail sets its own socket (RV-047 F-1).

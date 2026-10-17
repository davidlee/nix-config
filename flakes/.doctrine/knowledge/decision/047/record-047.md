# DEC-047: Broker serves one socket; jails reach it through a loopback relay and authenticate by key

<!-- Knowledge record body — context, detail, links. The structured, queried
     fields live in the sister `record-NNN.toml`; this prose is free-form and is
     never structurally parsed (the storage rule). -->

Amends DEC-046's clause "clients still reach the service through unix sockets
per trust class (file mode decides who connects)". The rest of DEC-046 stands.
Decided in the SL-011 design run (inq-2).

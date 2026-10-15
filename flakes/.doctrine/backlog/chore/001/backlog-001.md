# CHR-001: Retire modules/DESIGN.md into the composition tech spec

`modules/DESIGN.md` names `modules/home/nixos/` (actual: `modules/home/linux/`) and places code by evaluation class, which ADR-002 supersedes. Its configuration-style and update-semantics sections stay valid; fold them into the tech spec once the spike locks the structure.

# IMP-008: On-demand desktop app launchers

From the brief §6. A desktop entry invokes a wrapper that resolves and runs a pinned app at launch. Must not reference the app's store path or icons (that pulls it into the home closure); launch progress and failure visible; app build failures never break baseline builds. Start unrooted (ordinary GC collects). Open: QUE-003 (live checkout vs activated config). Candidates: Blender, CAD/drawing tools, LibreOffice.

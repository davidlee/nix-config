<!-- doctrine:section sec-1 -->
## Shape: options and files

Today the home side is flat. Sleipnir's `home.nix` imports
`profiles/linux-desktop.nix`, which pulls in all of `modules/home/{shared,linux}`,
and then lists the personal modules by hand. The cli package buckets
(`modules/shared/cli/_packages`) are split by a guess about platform, not by
function. After SL-008, every piece of home configuration sits in exactly one
of four places, the same classes SL-007 used for NixOS:

| class | where | who gets it |
|---|---|---|
| **home base** | `modules/home/default.nix` and the platform layer a host imports | every home (DEC-031) |
| **feature** | a record in `features/<area>.nix` | hosts that select it, directly or through a profile |
| **host config** | `hosts/<h>/home.nix` and files beside it | that host |
| **parked** | not imported | nobody, until it is repaired |

### The option tree

Markers:
- **P**: selected by `features/profiles/personal.nix`.
- **PL**: selected by `personal-linux.nix`.
- **W**: selected by `workstation.nix`.
- **S**: selected in `hosts/Sleipnir/features.nix`.
- **L**: the record has `platforms = lib.platforms.linux` (DEC-030).
- **g**: the record keeps today's `optionals isLinux` guard around its
  formerly Linux-only packages until P7 (§ CLI and editor features).

Every feature on this tree is new except where it says otherwise.

```
feature.
├── … existing areas unchanged (hardware session virt non-nix-packages games ai audio services
│     desktop compositor shell), except:
├── ai.claude-desktop                 L  S    modules/home/linux/ai.nix
├── audio.alarm                       L  S    modules/home/linux/alarm.nix + bin/spotify*; requires media.spotify
├── services.postgresql              (unchanged; S, and now also PL with mkDefault)
├── desktop.core                     changed  gains a homeManager half and L (§ Desktop and GUI)
├── shell.walker                      L  S    modules/home/linux/walker.nix
├── apps.cad                         moved → graphics.cad; apps area retired
├── editor.
│   ├── emacs                         g  P    emacs.nix (+ emacs-all-the-icons-fonts, guarded), EDITOR/VISUAL
│   ├── neovim                           P    nvim.nix + nvim-plugins.nix
│   ├── kakoune                       g  P    kakoune kakoune-lsp kakoune-cr
│   ├── misc                          g  P    wordgrinder, micro-with-wl-clipboard
│   ├── zed                           L  S    zed-editor
│   └── lem                           L  S    lem-ncurses
├── notes.
│   ├── terminal                      g  P    nb tpnote tui-journal kb
│   └── joplin                        L  S    joplin
├── dev.
│   ├── scm                           g  P    scm.nix minus git, + sublime-merge
│   ├── build                         g  P    build.nix
│   ├── runtimes                         P    nodejs_latest uv python3 mise
│   ├── runners                       g  P    just overmind watch watcher watchexec fswatch viddy entr watchman
│   └── tools                         g  P    exercism claude-monitor moreutils ccache gum tokei hyperfine
│                                             shellcheck shfmt
├── docs.
│   ├── diagrams                      g  P    graphviz d2 mermaid-cli structurizr-cli yed drawio
│   ├── typeset                       g  P    typst pandoc tdf ghostscript latex2html
│   ├── markdown                         P    glow rich-cli marksman markdown-oxide
│   └── help                          g  P    tealdeer cheat pinfo
├── data.
│   ├── structured                    g  P    jq xq yq-go jc jless gron otree jqp csv-tui
│   └── hex                           g  P    hexyl xxd
├── files.
│   ├── manage                        g  P    file managers, eza lsd pls tre bat, trash-cli, trashy
│   ├── disk                          g  P    ncdu gdu duf dust pydf, mmtui udiskie
│   ├── archive                          P    unar _7zz unrar p7zip
│   ├── search                        g  P    fd bfs ripgrep ripgrep-all ast-grep sad vgrep fzy mcfly docfd
│   │                                         nix-search-tv nix-search-cli fsearch
│   └── sync                          g  P    syncthing backintime
├── net.tools                         g  P    net.nix home lists minus curl wget openssl ddgr; + aria2
├── web.
│   ├── browsers                      L  W    browsers.nix (firefox, vivaldi, chromium, epiphany)
│   └── terminal                         P    w3m-full browsh lynx ddgr
├── system.
│   ├── monitor                       g  P    glances btop bottom htop gtop wtf tray-tui
│   └── process                       g  P    pstree killall await procs pueue mprocs stress-ng
├── text.
│   ├── tools                         g  P    sd choose play slides grex cicero-tui
│   ├── pagers                        g  P    nvimpager most moor ov chroma fltrdr
│   └── dictionary                    g  P    aspell gtt; sdcv + the web1913 dictionary (from emacs.nix, unguarded)
├── office.
│   ├── calc                             P    bc eva sc-im
│   └── calendar                      g  P    calcure gcalcli mpris-timer
├── security.
│   ├── credentials                      P    git-crypt gpgme gpg-tui oath-toolkit
│   └── research                         P    nvdtools seclists
├── media.
│   ├── view                          g  P    chafa viu ueberzugpp
│   ├── convert                       g  P    ffmpeg-full resvg
│   ├── players                       L  W    mpv vlc celluloid cmus asak playerctl viu (viu, 2nd mpv dropped in P7)
│   ├── spotify                       L  PL   spotify spotify-cli-linux spotifyd spotify-tray spotify-player
│   └── obs                           L  S    obs-studio + wlrobs; requires desktop.core
├── graphics.
│   ├── paint                         L  S    krita mypaint inkscape gimp drawpile penpot-desktop (graphics.nix)
│   ├── modelling                     L  S    blender (graphics.nix)
│   ├── color                            P    pastel
│   └── cad                              S    openscad (was apps.cad)
├── comms.
│   ├── chat                          L  W    beeper signal-desktop signal-cli qrencode discord element-desktop
│   ├── mail                          L  W    thunderbird-latest
│   └── feeds                         g  P    rssguard russ tut tuisky wiki-tui circumflex
├── fun.toys                          g  P    figlet fastfetch fortune cmatrix nms
├── terminal.
│   ├── emulators                     L  W    foot ghostty kitty
│   └── utils                         g  P    tmux zmx clock-rs asciinema nerd-font-patcher
├── attention.
│   ├── behaviour                     L  PL   behaviour.nix (panopticon)
│   ├── nudge                         L  PL   nudge.nix + nudge/*.nu
│   └── goad                          L  PL   goad.nix
└── satan.
    ├── harness                       L  PL   satan.nix; requires editor.emacs
    ├── patcher                       L  PL   satan-patcher.nix; requires services.postgresql
    └── attrd                         L  PL   satan-attrd.nix; requires services.postgresql
```

**The taxonomy rule** (DEC-032): areas are grouped by function, not by whether
an app is GUI or TUI. Each former cli file or GUI module maps to about one
feature, and broad files are split by job (display, filetypes, fileutils,
office, dev, security, graphics). A feature is split where a host would
plausibly select its parts independently. The membership of each feature is listed package by package in
§ CLI and editor features. The user's polish notes (2026-10-16) are already
applied: `terminal.utils`, `office.{calc,calendar}`, `text.dictionary`, and
the split of `data`.

**Who selects what** (DEC-024, DEC-033):
- **`personal`** selects the editors and every cli-derived feature. These are
  portable records, so this preserves Draupnir's current packages.
- **`personal-linux`** adds the Linux-only personal tools.
- A product bundle (`web.browsers`, `terminal.emulators`, …) is one switch.
  A host that wants less turns the feature off and lists packages in host
  config; per-product features wait for a second workstation.
- **`workstation`** adds what any desktop workstation of the user's wants:
  browsers, terminal emulators, chat, mail and media players.
- **Sleipnir** selects taste and per-machine use: graphics.{paint,modelling,cad}, obs,
  zed, lem, joplin, claude-desktop and walker, and `audio.alarm`, which is
  bound to this machine's speakers and Spotify Connect name.

No feature on the tree is off, so no new coverage target is needed for an off
feature. The new coverage target is the aarch64 home base (§ Verification
additions).

### Profiles

```
features/profiles/
  workstation.nix      + web.browsers terminal.emulators comms.chat comms.mail media.players
  personal.nix         new  editor.{emacs,neovim,kakoune,misc}, the cli features   (portable)
  personal-linux.nix   new  imports personal; satan.*, attention.*, media.spotify,
                            services.postgresql
  personal-darwin.nix  new  imports personal; nothing of its own yet (goad: IMP-023)

hosts/Sleipnir/features.nix   imports workstation + personal-linux; + its host selections
hosts/Draupnir/features.nix   new; imports personal-darwin
```

### The file tree

```
modules/home/
  default.nix          new   the home base: imports below + base cli (§ The home base)
  zsh.nix nushell.nix programs.nix shpool.nix cli.nix   moved up from shared/
  linux/default.nix    rewritten  the Linux layer: imports ../ ; sessionVariables
  linux/eca.nix  linux/chatgpt.nix      stay until W2 (named exception)
  darwin/default.nix   moved from darwin/home.nix
  (shared/ and every other linux/*.nix gone: moved into features or host config)

modules/shared/cli/    gone; its lists move into features, the base cli and the NixOS base
modules/nixos/cli.nix  holds the linuxSystem list inline

features/
  default.nix          areas take { lib }; + editor notes dev docs data files net web system
                       text office security media graphics comms fun terminal attention satan;
                       − apps
  <area>.nix           one per new area; cli lists inline
  editor/emacs.nix     own file (emacs.nix is ~50 lines plus EDITOR)
  editor/neovim/       nvim.nix, nvim-plugins.nix: modules the record imports (ADR-002 D3)
  desktop/core/home.nix  new  the desktop.core home half
  audio/alarm/         spotify-alarm, spotifyd-watchdog (assets)
  attention/behaviour.nix  own file;  attention/nudge/  main.nu nudge.nu nudge-test.nu
  satan/{harness,patcher,attrd}.nix   own files (the three together exceed 150 lines)
  profiles/{personal,personal-linux,personal-darwin}.nix   new

hosts/Sleipnir/
  home.nix             imports ../../modules/home/linux, ./doctor.nix, eca, chatgpt
  doctor.nix + doctor/ sleipnir-doctor home.file and its three scripts
  features.nix         + personal-linux import, + host selections
hosts/Draupnir/
  home.nix             imports ../../modules/home/darwin
  features.nix         new

profiles/              gone
darwin/home.nix        gone (→ modules/home/darwin/default.nix)
modules/home/linux/{bough,slk,helix}.nix   parked, stay; break-remind.nix deleted in P7
```

`modules/home/` then holds only the base, its two layers, the two W2
exceptions (eca, chatgpt) and the three parked files. Files that move whole are
moved with `git mv`, so history follows them.

<!-- doctrine:section sec-10 -->
## Platform scope in the resolver

DEC-030 answers QUE-001. A record may declare the systems it supports:

```nix
{
  name = "browsers";
  platforms = lib.platforms.linux;     # list of system strings; absent = every system
  homeManager = …;
}
```

### What changes in `features.nix`

```
resolve :: lib -> { tree, classes, system, modules } -> { modules }      (DEC-006: + system)
```

1. **Allowed keys**: `platforms` joins
   `["name" "nixos" "homeManager" "darwin" "requires"]` (`features.nix:120`).
2. **Shape**: `badShapes` gains a check that `platforms`, where present, is a
   list of strings. This reuses the existing `strings` helper, beside the
   `requires` check. A record with a bad shape is reported on its own, as
   today.
3. **Selection check**: each selected record gets a third assertion, next to
   the `requires` and "lands somewhere" (ADR-005 D6) checks:

   ```nix
   {
     assertion = lib.elem system (r.descriptor.platforms or [system]);
     message = "feature.${r.path} is selected but does not support ${system} (platforms: …)";
   }
   ```

   The resolver reads `platforms`, a list of strings, and nothing else of the
   record. It never forces a class value, so ADR-002 D4's "reads only key
   names, name, requires …" gains `platforms`, and nothing more.
4. The header comment and the descriptor description change to match.

Refusal, not skipping. A profile selection of an unsupported feature fails
resolution. Profiles stay plain `mkDefault` data and are split by platform
(`personal-linux`, `personal-darwin`). The host's import line is where the
platform choice is visible.

### Where `system` comes from

In `hosts.nix`, `select` passes `system = meta.system` (`hosts.nix:51-58`).
Every host's `meta.nix` already carries `system`. The `coverage.*` entries that
reuse `select` inherit it. `base@aarch64-linux` and the new home target bypass
`select` and need nothing.

### Area files take `lib`

Area files are plain lists today (`features/default.nix` does
`value = import ./<area>.nix;`), so a record cannot write `lib.platforms.linux`.
The tree becomes a function:

```nix
# features/default.nix
{lib}: let
  area = name: { inherit name; value = import ./${name}.nix {inherit lib;}; };
in map area [ "hardware" "session" … "satan" ]
```

Every area file then begins `{lib, ...}:`, or `_:` where it needs nothing.
The caller changes from `tree = import ./features` (`hosts.nix:35`,
`features-test.nix:8`) to `import ./features {inherit lib;}`. Feature records
stay plain data (ADR-002 D1). Only the file that lists them becomes a function.
Projection order is still the list order (ADR-002 D5).

The `map area [names]` form also removes the repeated `{ name; value = import … }`
blocks. It is a refactor with no behaviour change. The resolver tests prove
the tree is unchanged: `testSleipnirSelectsMigrated` and friends keep their
expected values in P1.

`system` is required, with no default: a caller that forgets it fails
instead of passing every platform check. So P1 updates every direct call of
`resolve` in `features-test.nix` (the `resolves` helper at `:23`, and the
calls at `:42`, `:56`, `:69`, `:150`, `:185`, `:243`, `:271` and `:281`). Each
gets the system its fixture means: `x86_64-linux` for Sleipnir and the
generic fixtures, `aarch64-darwin` for the Mac fixtures. A structural-error
fixture and its passing twin use the same system.

### Resolver tests (red first, P1)

- `testUnsupportedPlatformFails`: a fixture record with
  `platforms = ["x86_64-linux"]`, selected with `system = "aarch64-darwin"`, is
  refused. Its twin, with `system = "x86_64-linux"`, resolves. The pair has the
  `[fixture twin] → [false true]` shape.
- `testPlatformsAbsentMeansAll`: a record without `platforms` resolves under
  every system.
- `testBadPlatformsShapeFails`: `platforms = "linux"` (a string, not a list)
  is a structural error. Its twin, `["x86_64-linux"]`, resolves.
- `resolves` gains `system` (default `"x86_64-linux"`), like `classes`.
  `fails` takes an expression, so its callers pass `system` to `resolve`
  directly.

### Governance

One REV on ADR-002 covers D1 and D4 (the new key) and D5 (DEC-035's wording).
A REV on ADR-005 extends D6: "… an error; so is a selected feature whose
`platforms` omit the host's system". It also replaces the Neutral clause "no
support metadata until needed" with a pointer to DEC-030. DEC-006's signature
gains `system`. DEC-007's D6 sentence is unchanged. Both REVs are raised
before P1, so the code never contradicts accepted governance, and they are
applied through `/reconcile` (as REV-006 was for SL-007).

<!-- doctrine:section sec-2 -->
## The home base

DEC-031 mirrors DEC-027. The base is a plain import list, imported by the host,
with no switch and no factory change (DEC-016 keeps one injected module per
evaluation). Home Manager cannot choose imports from `pkgs`, so the platform
split is two layers, and the host imports exactly one of them:

```
hosts/Sleipnir/home.nix ──> modules/home/linux/default.nix ──┐
                                                             ├──> modules/home/default.nix
hosts/Draupnir/home.nix ──> modules/home/darwin/default.nix ─┘
```

### `modules/home/default.nix`

```nix
{...}: {
  imports = [ ./zsh.nix ./nushell.nix ./programs.nix ./shpool.nix ./cli.nix ];
  programs.home-manager.enable = true;
}
```

- `zsh.nix`, `nushell.nix`, `programs.nix` (direnv, yazi) and `shpool.nix`
  move up from `shared/` unchanged.
- `programs.home-manager.enable` comes out of both `hosts/*/home.nix`. It was
  duplicated there.
- `cli.nix` holds the base cli inline, in today's bucket order:

  | from | base packages |
  |---|---|
  | shell-ux | starship carapace fzf atuin (Linux only, ISS-007, unchanged) zoxide skim |
  | zsh | zsh zstd zsh-autocomplete antidote |
  | fileutils | coreutils xz gnutar cpio zip unzip |
  | find | file findutils |
  | text | gnused gawk |
  | net | curl wget openssl |
  | display | less fontconfig |
  | scm | git |
  | security | gnupg |

  The criterion is what any home needs to function. A shell with its prompt
  and completion, core userland, fetching, git, and gnupg (git-crypt and
  signing need it). Everything else becomes a feature (§ CLI and editor
  features).

**What leaves the base:**
- **EDITOR/VISUAL** moves into `editor.emacs`. The base sets no `EDITOR`.
- **The emacs and neovim modules** become `editor.*`.
- **`shared/default.nix`** is dissolved, since `default.nix` replaces it.

### `modules/home/linux/default.nix`

```nix
{config, ...}: {
  imports = [../.];
  # GUI apps launched by the compositor never source a shell profile
  systemd.user.sessionVariables = config.home.sessionVariables;
}
```

`sessionVariables` stays in a base layer, not in a feature. If a feature owned
it, deselecting that feature would silently drop EDITOR for compositor-launched
apps. `services.systembus-notify` moves to `desktop.core`'s home half: it only
matters with a notification daemon, and Home Manager asserts it is Linux-only.

### `modules/home/darwin/default.nix`

This is today's `darwin/home.nix`, moved with `git mv` and changed in only
two ways:
- its imports become `[../.]`;
- its header comment names the new layout.

The two ISS-007 atuin workarounds stay as they are:
- the `mkForce false` here;
- the Linux-only `atuin` entry, which moves into the base `cli.nix`.

`kitty.darwinLaunchOptions` and `targets.darwin.defaults` stay too.

### Host files after P2

```nix
# hosts/Sleipnir/home.nix
{username, ...}: {
  imports = [
    ../../modules/home/linux
    # host config and W2 exceptions; the personal modules leave in P5
    …
  ];
  home = { inherit username; homeDirectory = "/home/${username}"; stateVersion = "24.11"; };
  services.systembus-notify.enable = true;   # until P3 moves it to desktop.core
}
```

Identity stays with the host: `homeDirectory` differs by platform, and the
username is per host (IMP-011). `stateVersion` stays per host, as in DEC-027.

`profiles/linux-desktop.nix` is removed in P2. Until P3–P5 move them into
features, the Linux layer temporarily imports the remaining
`modules/home/linux/*.nix` GUI modules, and Sleipnir's `home.nix` keeps its
personal imports. Draupnir loses nothing in P2: it already imports exactly the
shared modules, plus `cli.nix`, plus the darwin bits.

<!-- doctrine:section sec-3 -->
## Desktop and GUI features

### `desktop.core` gains a home half (ISS-008)

`desktop.core` is NixOS-only today (`features/desktop/core.nix`). P3 adds a
`homeManager` half that imports `features/desktop/core/home.nix`, a module the
record owns (ADR-002 D3). The half holds:

| from | what |
|---|---|
| `modules/home/linux/wayland.nix` | `home.pointerCursor` (phinger), and `services.kanshi` with `enable = false` and its profiles, verbatim |
| `compositor.niri`'s home half (`features/compositor.nix:47-61`) | `services.tailscale-systray.enable`; the `swaybg` user service and its wallpaper path |
| `hosts/Sleipnir/home.nix:28` | `services.systembus-notify.enable` |

Why these items belong to core and not to a compositor:
- **tailscale-systray** needs the tailscale daemon from the NixOS base.
- **swaybg** is bound to `graphical-session.target`.
- **systembus-notify** forwards system-bus notifications to whatever
  notification daemon the session runs.

All three serve any session, and today umbriel uses them through niri's record
(ISS-008). Under umbriel, behaviour is unchanged: niri and core are both
selected on Sleipnir, so the same modules land, in a different order.

`desktop.core` gains `platforms = lib.platforms.linux`. With a home half it
would otherwise pass D6 on darwin. The workstation profile, which selects it,
was already Linux-only (DEC-024).

niri's home half keeps `nirius`, vicinae and its HM module import. The ISS-008
comment (`compositor.nix:6`) goes.

### GUI features by function

Each GUI module from `modules/home/linux` becomes a feature verbatim, carrying
`platforms = lib.platforms.linux`. These modules were only ever on Linux, and
most of their packages are Linux-only.

| feature | source | selected by |
|---|---|---|
| `web.browsers` | `browsers.nix` (packages + `programs.firefox`, `firefoxpwa`) | W |
| `terminal.emulators` | `terminals.nix` | W |
| `comms.chat` | `office.nix`: beeper signal-desktop signal-cli qrencode discord element-desktop | W |
| `comms.mail` | `office.nix`: thunderbird-latest | W |
| `media.players` | `media.nix`: mpv playerctl viu asak cmus vlc celluloid | W |
| `media.spotify` | `media.nix`: the five spotify packages | PL |
| `media.obs` | `obs-studio.nix`; `requires = ["desktop.core"]` | S |
| `graphics.paint` | `graphics.nix`: krita, `stable.mypaint` (the `stable` module arg, unchanged), inkscape gimp drawpile penpot-desktop | S |
| `graphics.modelling` | `graphics.nix`: blender (not `3d`: a leading digit needs quoting as a Nix attribute) | S |
| `graphics.cad` | `features/apps.nix` record, renamed; no `platforms` (openscad is portable) | S |
| `editor.zed` | `zed-editor.nix` | S |
| `editor.lem` | `editors.nix`: lem-ncurses | S |
| `notes.joplin` | `editors.nix`: joplin | S |
| `ai.claude-desktop` | `ai.nix` | S |
| `shell.walker` | `walker.nix` (walker HM module, runAsService) | S |

`office.nix`'s `rssguard` goes to `comms.feeds`, and `mpris-timer` to
`office.calendar`, the area for keeping time. Both are cli-derived features
(§ CLI and editor features), and both keep their Linux guard.

`graphics.nix`'s yed and drawio go to `docs.diagrams`, with its Linux guard.
`docs.diagrams` is created in P4, so in P3 `graphics.nix` shrinks to those
two and stays imported by the Linux layer; P4 moves them and deletes it.
They were Sleipnir's selection and become `personal`'s, which on Linux is
the same host.

**`requires` is not a prerequisite check.** `media.obs` requires
`desktop.core` because wlrobs needs v4l2loopback, and v4l2loopback is in
core's NixOS half (`features/desktop/core/v4l2loopback.nix`). `requires`
checks only selection, so on a home-only Linux host both records would land
and v4l2loopback would not. No such host exists. If one appears, `media.obs`
needs a host-class check.

**Who selects** (DEC-024): the workstation profile takes what any desktop
workstation of the user's wants (a browser, a terminal, chat, mail, a media
player). Sleipnir selects taste and per-machine use. `media.spotify` is
selected by `personal-linux`. `audio.alarm`, selected by Sleipnir, requires it:
`bin/spotify-alarm` calls `spotify_player` from PATH (`spotify-alarm:47, :58`).

### Collision watch (gate)

These packages exist in both a system and a home profile, so they are
duplicated rather than colliding, and the gate confirms each:
- `foot` (`programs.foot` in core's `gui.nix`, and `terminal.emulators`);
- `swaybg` (core's `wayland_packages.nix`, and the core home service);
- the cursors (system phinger/bibata, and `home.pointerCursor`).

Until P7, `mpv` appears twice in `media.players`, as it does today, and `viu`
is in both `media.players` and `media.view`. A home profile builds one
`buildEnv`, so a duplicate is harmless. P7 removes them (§ Behaviour
changes). A flip in which package wins a colliding path means stop and
`/consult` (`mem.fact.nix.systempath-collision-first-wins`).

<!-- doctrine:section sec-4 -->
## CLI and editor features

### The rule during migration (P4)

Each cli-derived feature carries its packages inline in its area file, and
keeps today's platform split exactly:

```nix
{
  name = "build";
  homeManager = {pkgs, lib, ...}: {
    home.packages = with pkgs;
      [ gnumake ninja autoconf cmake bison gcc ]                 # was common
      ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [         # was linuxHome
        lldb lld llvm clangStdenv libclang binutils
      ];
  };
}
```

**These records carry no `platforms` key.** They are portable records, and on
darwin their Linux-only lists are empty. So `personal` can select every one of
them, and Draupnir keeps exactly today's `common` packages. P7 replaces each
guard with `lib.meta.availableOn` and a `brokenOn` list (DEC-036, § Behaviour
changes).

Within each feature, the package order follows the order of the source files.
`modules/shared/cli/default.nix` read `_packages/` in `readDir` order
(alphabetical by file), common before linuxHome. The order of the whole
`home.packages` list still changes, because features append after the host's
modules (DEC-007, and ADR-002 D5 as revised by DEC-035). The gate proves this
harmless.

### Mapping, file by file

| source (`_packages/`) | → feature, or base / NixOS base |
|---|---|
| `build.nix` | `dev.build`, all of it |
| `dev.nix` | nodejs_latest uv python3 mise → `dev.runtimes`. just overmind watch watcher watchexec fswatch viddy entr, watchman (guarded) → `dev.runners`. exercism claude-monitor moreutils, ccache (guarded) → `dev.tools`. The linuxSystem list (bubblewrap distrobox distrobox-tui valgrind strace) → NixOS base `modules/nixos/cli.nix` |
| `display.nix` | less, fontconfig → base. nvimpager most moor ov chroma fltrdr → `text.pagers`. graphviz d2 mermaid-cli structurizr-cli → `docs.diagrams`. tokei → `dev.tools`. pastel → `graphics.color`. chafa viu ueberzugpp → `media.view`. resvg ffmpeg-full → `media.convert`. asciinema nerd-font-patcher → `terminal.utils`. ghostscript latex2html → `docs.typeset` |
| `editors.nix` | wordgrinder, micro-with-wl-clipboard → `editor.misc`. kakoune kakoune-lsp kakoune-cr → `editor.kakoune`. nb tpnote tui-journal kb → `notes.terminal`. emacs-all-the-icons-fonts → `editor.emacs`, guarded (it is in linuxHome) |
| `filetypes.nix` | jq xq yq-go jc jless gron otree jqp csv-tui → `data.structured`. glow rich-cli marksman markdown-oxide → `docs.markdown`. hexyl xxd → `data.hex`. typst pandoc tdf → `docs.typeset`. gum → `dev.tools`. gcalcli → `office.calendar`. grex cicero-tui → `text.tools`. gtt → `text.dictionary`. circumflex → `comms.feeds` |
| `fileutils.nix` | coreutils xz gnutar cpio zip unzip → base. File managers, eza lsd pls tre bat, trash-cli, `hiPrio trashy` → `files.manage`. bfs → `files.search`. ncdu gdu duf dust pydf → `files.disk`. unar _7zz unrar p7zip → `files.archive`. syncthing backintime → `files.sync`. aria2 → `net.tools` |
| `find.nix` | file findutils → base. The rest, and fsearch → `files.search` |
| `frivolity.nix` | figlet fastfetch fortune cmatrix nms → `fun.toys`. russ tut tuisky wiki-tui → `comms.feeds` |
| `help.nix` | `docs.help` |
| `net.nix` | curl wget openssl → base. ddgr → `web.terminal`. The rest (yt-dlp included), and sn0int → `net.tools`. The linuxSystem list → NixOS base |
| `scm.nix` | git → base. The rest (`hiPrio gitFull`, gitui guarded) → `dev.scm`, plus sublime-merge (guarded) from `modules/home/linux/editors.nix` |
| `security.nix` | gnupg → base. git-crypt gpgme gpg-tui oath-toolkit → `security.credentials`. nvdtools seclists → `security.research` |
| `shell-ux.nix` | starship carapace fzf atuin zoxide skim → base. tmux zmx → `terminal.utils` |
| `system.nix` | glances btop bottom htop gtop wtf tray-tui → `system.monitor`. pstree killall await procs pueue mprocs stress-ng → `system.process`. hyperfine → `dev.tools`. mmtui udiskie → `files.disk`. The linuxSystem list → NixOS base |
| `text.nix` | gnused gawk → base. sd choose play slides → `text.tools`. aspell → `text.dictionary`. bc eva sc-im → `office.calc`. calcure → `office.calendar`. clock-rs → `terminal.utils` |
| `www.nix` | `web.terminal` |
| `zsh.nix` | zsh zstd zsh-autocomplete antidote → base. shellcheck shfmt → `dev.tools` |

**A moved package keeps its bucket's guard.** A `linuxHome` package is
guarded in its new feature even where the rest of the feature is common
(emacs-all-the-icons-fonts in `editor.emacs`, gtt in `text.dictionary`,
nerd-font-patcher in `terminal.utils`). A package from a home module keeps
that module's reach: `sdcv` and the web1913 `home.file` come from
`emacs.nix`, which both hosts import, so they stay unguarded.

`modules/shared/cli/` is then removed. `modules/nixos/cli.nix` holds the
linuxSystem list inline, with its `isx86` guards as they are until P7, so the
NixOS base needs no shared module.

A completeness check, run once in P4: the sorted union of every new list,
plus the base, plus the NixOS list, equals the sorted union of the old buckets.
Run it per system (x86_64-linux and aarch64-darwin), both as package-name sets
and as `drvs-sets`.

### Editors

- **`editor.emacs`** (`features/editor/emacs.nix`, its own file): today's
  `emacs.nix` with two changes:
  - it gains `home.sessionVariables.{EDITOR,VISUAL}`, and
    emacs-all-the-icons-fonts under the Linux guard;
  - it loses `sdcv` and the web1913 `home.file`, which move to
    `text.dictionary`. Emacs's quick-sdcv needs both, and `personal` selects
    both. The dependency is soft (the editor works without it), so there is
    no `requires`.

  It also drops `imports = [./shpool.nix]`. That import duplicated the base's
  shpool import, so dropping it changes no derivation. It is also IMP-001's
  first step.
- **`editor.neovim`**: imports `features/editor/neovim/{nvim,nvim-plugins}.nix`,
  modules the record owns. `options.nvimPackages` is declared only when
  neovim is selected, and only `nvim.nix` reads it (`nvim.nix:7`).
- **`editor.kakoune`, `editor.misc`**: cli-derived, guarded as above.
- The `emacs` and `neovim-nightly-overlay` inputs are reached only through
  these records. A home without them never fetches either.

### Guarded features on darwin

| feature | content on Draupnir (aarch64-darwin) |
|---|---|
| `editor.emacs`, `editor.kakoune`, `notes.terminal`, `text.dictionary`, `data.hex`, `docs.help`, `comms.feeds`, `files.sync`, … | the common part only; may be empty |
| `office.calc`, `docs.markdown`, `files.archive`, `security.{credentials,research}`, `dev.runtimes`, `graphics.color`, `web.terminal` | everything (wholly common) |

An empty `home.packages` is harmless, and P7 fills it from availability.

<!-- doctrine:section sec-5 -->
## Personal

DEC-033. "Personal" means the machines the user owns. Sleipnir imports
`personal-linux` and Draupnir imports `personal-darwin`. Both import
`personal`. A work machine imports neither.

```
personal-linux ──imports──┐                  ┌──imports── personal-darwin
  satan.{harness,patcher,attrd}             │              (nothing yet; goad: IMP-023)
  attention.{behaviour,nudge,goad}          ▼
  media.spotify                        personal
  services.postgresql (mkDefault)        editor.{emacs,neovim,kakoune,misc}
                                         every cli-derived feature
```

### Records

| feature | file | requires | notes |
|---|---|---|---|
| `satan.harness` | `features/satan/harness.nix` (from `satan.nix`) | `editor.emacs` | `satan-run` needs `emacsclient` (`satan.nix:10`) |
| `satan.patcher` | `features/satan/patcher.nix` | `services.postgresql` | DSN `postgres:///satan_memory?host=/run/postgresql` (the module default) |
| `satan.attrd` | `features/satan/attrd.nix` | `services.postgresql` | as above |
| `attention.behaviour` | `features/attention/behaviour.nix` | none | panopticon services and timers |
| `attention.nudge` | inline in `features/attention.nix`, assets in `features/attention/nudge/` | none | see below |
| `attention.goad` | inline | none | systemd-only HM module; a darwin half later (IMP-023) |
| `audio.alarm` | inline in `features/audio.nix`, assets in `features/audio/alarm/` | `media.spotify` | selected by Sleipnir, not `personal-linux`: the Spotify Connect device name `Sleipnir` and the speaker stay hard-coded (W9). `spotify-alarm` calls `spotify_player` from PATH (`:47, :58`) |

Each of these records carries `platforms = lib.platforms.linux`. Selecting one
on Draupnir is refused at resolve time, not left inert.

Area order: `attention` and `satan` are the last two areas in
`features/default.nix`.

**`requires` across halves.** `satan.patcher` is a home half, and
`services.postgresql` is a NixOS half. `requires` checks only the selection
(ADR-003: the home cannot read the system), which is the coupling EVD-001
found. `personal-linux` selects postgresql with `mkDefault`, as ADR-001 D4
asks. Sleipnir's plain selection of postgresql also stays.

### nudge moves its runtime path

`nudge.nix:19` runs `nu ~/flakes/modules/home/linux/nudge/main.nu` from the
live checkout, not the store. Moving the `.nu` files changes that string, and
so the unit's derivation. P5 updates three things together:
- the path in the unit, to `~/flakes/features/attention/nudge/main.nu`;
- the comments at `nudge.nix:7-8`;
- the `justfile:52` test recipe.

This is P5's one allowed non-order diff. The negative control is that the old
path is gone from the unit text.

### sleipnir-doctor is host config

`modules/home/linux/sleipnir-doctor.nix` and `bin/sleipnir-doctor*` move to
`hosts/Sleipnir/doctor.nix` and `hosts/Sleipnir/doctor/`. The doctor is named
for one host and checks that host's services.

The `home.file` sources keep their basenames, so their store paths are
unchanged. Its first comment, which says python comes from sway's
`wpmPython`, is corrected. The scripts use only the standard library, and P4
moves `python3` into `dev.runtimes`. Sleipnir selects `dev.runtimes` through
`personal`, and P7 pins the interpreter (§ Behaviour changes).

### Draupnir

`hosts/Draupnir/features.nix` (new) imports `personal-darwin`. Draupnir's
selection goes from empty to:
- `editor.{emacs,neovim,kakoune,misc}`;
- the cli-derived features.

Its packages stay the same, as § CLI and editor features shows. This is the
first darwin host with a selection, so `testMacSelectsNothing` becomes
`testDraupnirSelection` (§ Verification additions).

<!-- doctrine:section sec-6 -->
## Verification additions

DEC-034.

### `coverage."home@aarch64-linux"` (P6)

This target is the home analogue of `coverage."base@aarch64-linux"`. It builds
the home base and the Linux layer with stub identity, no host and no
selection. It calls `homeManagerConfiguration` directly, because `mkHome`
hard-codes `hosts/<h>/home.nix` (`hosts.nix:115`):

```nix
coverage."home@aarch64-linux" = inputs.home-manager.lib.homeManagerConfiguration {
  pkgs = import inputs.nixpkgs-home {system = "aarch64-linux";};
  modules = [
    (homeModule "aarch64-linux")
    ./modules/home/linux
    { home = { inherit username; homeDirectory = "/home/${username}"; stateVersion = "24.11"; }; }
  ];
  extraSpecialArgs = args "home-base";
};
```

It shows that the base evaluates headless and off x86, and it pre-pays W7. It
does not reach the `emacs` or neovim inputs any more, because those are
features now. It still reaches `agents`, through `homeModule`'s overlay
(ISS-006), so it needs `agents_override`.

### `just coverage` learns home targets

Today the recipe applies `nixos_pick` to every `coverage.*` attribute
(`justfile:107-108`). The new pick branches:

```
c: if c ? activationPackage then c.activationPackage.drvPath else (<nixos_pick> c)
```

The recipe passes `system_override` plus `home_override` (the `emacs` path
override is harmless when nothing reaches it).

### The isolation check (committed)

A local-path input is one whose `flake.nix` URL is a path or `git+file:` URL
on this machine (panopticon, satan-patcher, satan-attrd, goad).

- **The stub.** `features/stub/flake.nix` (tracked) contains only
  `{ outputs = _: {}; }`. Pointing at a stub rather than a missing path
  avoids a fetch failure when the lock is read (research § Local-path input
  references).
- **The recipe.** A new `just isolation` evaluates two homes with those four
  inputs overridden to the stub (`--override-input <name> path:./features/stub`):
  - `coverage."home@aarch64-linux"`;
  - `homeConfigurations."david@Draupnir"`.
- **What fails.** Any reference to `inputs.<name>.packages` or
  `inputs.<name>.homeManagerModules` then fails evaluation, with a missing
  attribute error that names the input. A reference to the input itself (its
  `outPath`, say) still evaluates and is not caught. Every reference research
  found uses one of those two attributes (research § Local-path input
  references), so the check covers today's code, not every possible use.
- **When it runs.** `just coverage` calls it, so it runs wherever coverage
  runs (outside `just drvs`, DEC-008).

Draupnir is included because, until a darwin feature needs a local input
(IMP-023), its home must not reach one. When IMP-023 lands, Draupnir leaves
the recipe, and the change says why.

Negative control (once, P6): temporarily select `attention.goad` in the
target's modules, through a resolver call with the target's own system,
`aarch64-linux` (`goad`'s `platforms = lib.platforms.linux` admits it). The
isolation recipe must then fail with the missing-attribute error on `goad`'s
input, and on nothing else.

### Resolver tests

These are in addition to P1's platform tests (§ Platform scope).

| test | phase | asserts |
|---|---|---|
| `testSleipnirHomeSelection` | P3–P5 | Sleipnir's real `features.nix` selects each new feature, with `#homeManager` tags, `[true]`. The list grows per phase |
| `testPersonalSelectsPortable` | P5 | `personal` alone, `system = "aarch64-darwin"`, `["darwin" "homeManager"]`: resolves; selects `editor.emacs`, `editor.neovim`, and no record that carries `platforms` |
| `testPersonalLinuxOnDarwinFails` | P5 | `personal-linux` with `system = "aarch64-darwin"` is refused (satan.* platforms); with `x86_64-linux` it resolves |
| `testDraupnirSelection` | P5 | replaces `testMacSelectsNothing`: Draupnir's real `features.nix`, its real classes and system; resolves; selects exactly `personal`'s set |
| `testPersonalRequires` | P5 | `satan.patcher` without `services.postgresql`, `satan.harness` without `editor.emacs`, and `audio.alarm` without `media.spotify` are each refused |
| `testAlarmIsHostSelected` | P5 | `personal-linux` alone, `x86_64-linux`: resolves and does not select `audio.alarm` |
| `testObsRequiresCore` | P3 | `media.obs` without `desktop.core` is refused |
| `testDesktopCoreLinuxOnly` | P3 | `desktop.core` on `aarch64-darwin` is refused |

`testOffFeatures` is unchanged, because no new feature is off. The factory
check (`hosts.nix:182-185`) is unchanged.

<!-- doctrine:section sec-7 -->
## Behaviour changes (P7)

This is the only phase that is allowed to change content. Each row is a
deliberate change, and nothing outside the table may differ.

| change | effect | proof |
|---|---|---|
| **cli availability** (DEC-036): every guarded feature's `optionals isLinux [ … ]` becomes one list, `filter (availableOn hostPlatform) (subtractLists (brokenOn.${system} or []) all)` | Draupnir gains the packages available on aarch64-darwin. Sleipnir is identical | Sleipnir `drvs-sets` home identical. Draupnir `drvs-sets` home count rises by exactly the evaluated delta, whose package names are listed in the phase notes. The home filter is exercised on x86_64-linux (Sleipnir) and aarch64-darwin (Draupnir). `coverage."home@aarch64-linux"` selects no feature, so it does not reach it; aarch64-linux homes with features are W7's |
| **`brokenOn`** (one attrset, `features/cli-broken.nix`): `aarch64-darwin = [watchman atuin]`. atuin is there while ISS-007 stands; watchman's C++ tower fails on darwin (`dev.nix` comment) | they stay off the Mac | neither name is in Draupnir's `home.packages` |
| **NixOS `isx86` guards** in `modules/nixos/cli.nix` (cpuid, x86info) → `availableOn` | none on x86_64 | Sleipnir system `drvs-sets` identical. `base@aarch64-linux` still evaluates |
| **doctor interpreter**: the three `home.file` entries become `pkgs.writeScript` with an explicit `python3` shebang, or `source` plus a pinned interpreter | the doctor no longer depends on PATH `python3` | the scripts run (`sleipnir-doctor` exits 0 or reports checks) |
| **duplicates removed**: the second `mpv` and `viu` from `media.players` (`viu` stays in `media.view`); `yazi` from `files.manage` and `mcfly` from `files.search`, which the base's `programs.yazi` and `programs.mcfly` already install | none, if the HM program's package is the one that wins today | Sleipnir home probe: `home-path-links` identical. If the bare `yazi` or `mcfly` wins a path today, that row is dropped and recorded, not forced |
| **`break-remind.nix` deleted** | none (imported nowhere) | `git grep break-remind` under `flakes/` finds only the README parked note, if any |
| **comments and docs**: the `workstation.nix` comment (dictate would not fail D6 on darwin; that profile is Linux-only now through `desktop.core`'s platforms); the README; DEC-024's darwin consequence | none | review |

### Before P7: the darwin build check

`lib.meta.availableOn` is metadata only. It is true when `meta.platforms`
includes the platform or is absent, and false when `meta.badPlatforms`
matches. It says nothing about whether a package builds, is cached, or works.
What P7 guarantees is therefore narrow: the metadata filter, evaluation on
Sleipnir and Draupnir (and the NixOS filter on `base@aarch64-linux`), and the
cache check below. Before P7 is committed:
1. Every package Draupnir gains is checked against the cache with
   `nix path-info --store https://cache.nixos.org <outPath>`.
2. Packages that are not cached are listed in the phase notes.
3. The user chooses for each: add it to `brokenOn`, or accept a local build at
   the next `darwin`/`home-switch`.

Draupnir cannot be switched from Sleipnir, so the switch itself is the user's.
This check does not replace it: whether the added tools build locally and
activate is known only at the user's next Draupnir `home-switch`.

**Why not mark `platforms` on the cli features instead:** that would freeze
today's guess. With `availableOn`, aarch64-linux (W7) gets the right set
automatically.

<!-- doctrine:section sec-8 -->
## Phases and verification

The SL-006 and SL-007 gate carries over (`mem.pattern.flakes.drv-gate`). Run
`just drvs`, `drvs-sets`, `probe`, `coverage` and `gate` before the first
edit and after each phase, and compare each phase with the one before.

An ordering-only diff is accepted under ADR-002 D5 as revised (DEC-035) when
either:
- every probe measure is identical; or
- the only changed measure is a built artefact whose drv `nix-diff` shows
  differs only by list order.

A flipped collision winner means stop and `/consult`.

**Darwin has no probe.** A darwin home cannot be built on Sleipnir, so
Draupnir's home and system are checked by `drvs` and `drvs-sets` only. Where
Draupnir's home drv changes, its `drvs-sets` must match, and a `nix-diff` of
its `home-manager-generation` must show order only. Neither shows a flipped
collision winner. Two things close most of that gap:
- **Sleipnir's probe stands proxy.** Draupnir's `home.packages` is Sleipnir's
  list with the guarded entries removed, in the same feature and source
  order; the darwin layer adds no `home.packages` of its own. So any
  collision between two packages Draupnir has is also a collision on
  Sleipnir, in the same relative order, and Sleipnir's `home-path-links`
  would show it flip. The residue is packages whose file sets differ by
  platform, and HM `programs.*` packages from the darwin layer (kitty).
- **A link-map check at the next Draupnir switch (VH, by the user).** Before
  activating, the user runs `bin/gate-probe` on Draupnir against the new
  home and compares its `home-path-links` with the current generation's
  `home-path`. A flipped winner there is fixed forward.

**New files are tracked before evaluation** (`mem.fact.flakes.git-add-n`).
Every new file is `git add -N`ed before the phase's gate runs.

**Baselines are taken close together.** `emacs-overlay` re-resolves and moves
home and darwin (RFC-001 working rules), so each phase takes its "before"
snapshot immediately before editing.

| # | phase | allowed diff | proof |
|---|---|---|---|
| P1 | **resolver**: `platforms` key, `system` arg, tree takes `{lib}` (`map area`), tests; REVs on ADR-002 and ADR-005 raised | none | every `drvs` line identical; `just test` green, new tests red first |
| P2 | **home base**: `modules/home/default.nix`, the linux and darwin layers, `cli.nix` still importing `modules/shared/cli`; `programs.home-manager.enable` into the base; `profiles/` and `darwin/home.nix` removed | order only: Sleipnir and Draupnir homes | Sleipnir home probe identical; Draupnir home `drvs-sets` identical and `nix-diff` order-only |
| P3 | **desktop and GUI**: `desktop.core` home half (ISS-008, systembus-notify, wayland.nix), `platforms` on core; `web.browsers`, `terminal.emulators`, `comms.{chat,mail}`, `media.{players,spotify,obs}`, `graphics.{paint,modelling,cad}` (apps area gone; `graphics.nix` keeps yed and drawio until P4), `editor.{zed,lem}`, `notes.joplin`, `ai.claude-desktop`, `shell.walker`; workstation + Sleipnir selections | order only: Sleipnir home (`home.packages`, user units). Draupnir identical | Sleipnir home probe identical; system identical |
| P4 | **cli and editors**: every cli-derived feature, `editor.{emacs,neovim,kakoune,misc}`, `notes.terminal`; yed and drawio into `docs.diagrams`, `graphics.nix` deleted; base `cli.nix` inline; `modules/shared/cli` removed; `modules/nixos/cli.nix` inline. `personal` created with these, imported by Sleipnir; Draupnir `features.nix` imports `personal` directly until P5 | order only: both homes; Sleipnir system `systemPackages` order (cli.nix inline) | completeness check (§ CLI and editor features); both homes' `drvs-sets` identical; Sleipnir probe identical; system `drvs-sets` identical |
| P5 | **personal**: `satan.*`, `attention.*`, `audio.alarm`; `personal-linux`, `personal-darwin`; Sleipnir → `personal-linux` (its `media.spotify` and `services.postgresql` selections stay, now also defaulted by the profile) and selects `audio.alarm`, Draupnir → `personal-darwin`; doctor → host config | order only, plus nudge's script path in its unit | Sleipnir home probe identical except the nudge unit, whose only diff is the path; Draupnir identical to P4 |
| P6 | **verification**: `coverage."home@aarch64-linux"`, the coverage pick, the stub flake, `just isolation` | `coverage` gains one line | all `drvs` lines identical; the new target evaluates; isolation passes; the negative control fails as specified |
| P7 | **behaviour** (§ Behaviour changes) | exactly that table | as in the table |

One commit per phase.

### Negative controls

These are one-off evaluations, not committed
(`mem.fact.nix.verify-closure-not-option`). Deselect with `lib.mkForce false`
and check the closure, not just the option.

| feature | signature gone |
|---|---|
| `editor.emacs` | `emacs` absent from `home-path`; `EDITOR` unset in `hm-session-vars.sh`; `emacs.service` absent |
| `editor.neovim` | `nvim` absent from `home-path` |
| `dev.scm` | `lazygit` and `jujutsu` absent; `git` still present (base) |
| `terminal.utils` | `tmux` absent from `home-path` |
| `desktop.core` (home half, with the compositors) | no `swaybg.service` and no `tailscale-systray.service` in the home; `home.pointerCursor` unset |
| `compositor.niri` alone | `swaybg` and `tailscale-systray` **still** present (ISS-008 fixed) |
| `attention.nudge` | no `nudge.service`/`.timer` |
| `satan.patcher` | no `satan-patcher.service` |
| `media.obs` | `programs.obs-studio` absent |
| one cli feature on Draupnir (`docs.markdown`) | `glow` absent from Draupnir's `home.packages` |

The refusal controls are checked once:
- `web.browsers` selected on Draupnir is refused, naming `aarch64-darwin`;
- `satan.patcher` with `services.postgresql = mkForce false` is refused.

### Close

- `profiles/`, `darwin/home.nix` and `modules/shared/cli/` are gone.
- `ls modules/home` shows only `default.nix`, the base modules, `linux/` and
  `darwin/`.
- `ls modules/home/linux` shows `default.nix`, `eca.nix`, `chatgpt.nix` and
  the three parked files.
- `git grep -En 'profiles/linux-desktop|darwin/home\.nix|modules/shared/cli|modules/home/(shared|linux/(alarm|behaviour|goad|nudge|satan|walker|browsers|media|office|graphics|terminals|wayland|zed-editor|editors|obs-studio|ai|sleipnir-doctor)))'`
  over tracked files under `flakes/`, excluding `.doctrine/`, finds nothing.
- `just gate` and `just coverage` (with isolation) are green.

<!-- doctrine:section sec-9 -->
## Code impact and docs

### Files

| path | change | phase |
|---|---|---|
| `features.nix` | `platforms` key, shape and assertion; `system` argument; header | P1 |
| `features-test.nix` | platform tests; tree via `{lib}`; selection tests | P1, P3–P5 |
| `features/default.nix` | `{lib}: map area [ … ]`; new areas; `apps` gone | P1, P3–P5 |
| `features/*.nix` (every area file) | `{lib, ...}:` / `_:` header | P1 |
| `hosts.nix` | `select` passes `system`; `tree` via `{lib}`; `coverage."home@aarch64-linux"` | P1, P6 |
| `modules/home/default.nix`, `cli.nix`, `linux/default.nix`, `darwin/default.nix` | new or rewritten | P2, P4 |
| `modules/home/shared/*` | moved up or into `features/editor/` | P2, P4 |
| `modules/home/linux/*.nix` | moved into features or host config; `break-remind` deleted | P3–P5, P7 |
| `modules/shared/cli/**` | removed; its lists are inlined | P4 |
| `modules/nixos/cli.nix` | linuxSystem list inline; `availableOn` in P7 | P4, P7 |
| `features/{editor,notes,dev,docs,data,files,net,web,system,text,office,security,media,graphics,comms,fun,terminal,attention,satan}.nix` | new area files | P3–P5 |
| `features/editor/`, `features/desktop/core/home.nix`, `features/attention/`, `features/satan/`, `features/audio/alarm/` | new | P3–P5 |
| `features/compositor.nix` | niri home half loses tailscale-systray and swaybg | P3 |
| `features/desktop/core.nix` | `homeManager` half, `platforms` | P3 |
| `features/apps.nix` | removed (cad → graphics) | P3 |
| `features/profiles/*` | workstation extended; three personal profiles | P3–P5 |
| `features/stub/flake.nix`, `features/cli-broken.nix` | new | P6, P7 |
| `hosts/Sleipnir/{home,features,doctor}.nix`, `hosts/Sleipnir/doctor/` | rewritten or new | P2–P5 |
| `hosts/Draupnir/{home,features}.nix` | rewritten or new | P2, P4–P5 |
| `profiles/linux-desktop.nix`, `darwin/home.nix` | removed | P2 |
| `justfile` | `coverage` pick; `isolation`; the nudge test path | P5, P6 |

### Governance (through REVs, applied at `/reconcile`)

- **ADR-002**: D1 and D4 gain `platforms`. D5 is reworded (DEC-035).
- **ADR-005**: D6 extended to cover unsupported platforms. The Neutral
  clause is updated.
- **DEC-006**: the signature gains `system`.
- **DEC-024**: the darwin consequence is refreshed.
- **QUE-001**: answered (DEC-030), done.
- **IMP-016**: resolved by DEC-032 at close.
- **ISS-008**: resolved at close.
- **RFC-001**: the W5 row and § Target shape are updated (profiles: personal
  is three files; headless is still W7's).

### Docs

- **README § Features**:
  - the feature tree listing (new areas, `apps` gone);
  - profiles;
  - the darwin paragraph: replace "not refused (QUE-001)" with the
    `platforms` rule;
  - the coverage list (home target, isolation).
- **README § Hosts**: a home row in the base / feature / host table, and
  `modules/home/` described like `modules/nixos/`.
- **README § Emacs**: `modules/home/shared/emacs.nix` becomes
  `features/editor/emacs.nix`.
- **README stale pointers**: `modules/home/nixos/…` at `:361` and `:557`
  are already wrong. Fix them to their new homes.
- **`SATAN.md:17-23`**: the module paths become `features/satan/*`.
- Each move's paths are fixed in the same phase as the move.

### Design-target selectors

These are recorded with `doctrine slice selector add 8 … --intent design-target`:

```
features.nix  features-test.nix  hosts.nix  justfile  README.md  SATAN.md
features/**   modules/home/**   modules/shared/cli/**   modules/nixos/cli.nix
hosts/Sleipnir/home.nix  hosts/Sleipnir/features.nix  hosts/Sleipnir/doctor.nix  hosts/Sleipnir/doctor/**
hosts/Draupnir/home.nix  hosts/Draupnir/features.nix
profiles/**  darwin/home.nix
```


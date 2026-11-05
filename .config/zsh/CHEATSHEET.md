# zsh cheatsheet

## edit
| cmd | does |
|---|---|
| `e f…` | emacsclient: reuse GUI frame, no wait (tty w/o display) |
| `e -t\|-c\|… f…` | options replace the default mode |
| `ez [opts] [q]` | edit picked file under git root, or zoxide dir for `q` |
| `ne [opts] [q]` | edit picked note (~/notes, org/md); `q` pre-fills fzf |
| `et` `ec` `en` `ee` | emacsclient `-t` / `-c` / `-n` / `--eval` |

## go
| cmd | does |
|---|---|
| `cz [q]` / `czh [q]` | cd to picked subdir of git root / zoxide dir (`h`: hidden) |
| `cfg` | cd to picked dir under ~/.config |
| `ch` | cd to a favourite dir |
| `gr` | cd to git root |
| `cd q` / `zi` | zoxide jump / interactive |

## pick
| key / cmd | does |
|---|---|
| `C-t` | tv: insert path; channel follows the command (`leaf` → markdown incl. `.doctrine`, else files) |
| `M-c` | fzf: cd to picked dir |
| `zx` | zmx session picker | 
| `path/**<TAB>` | fzf completion under `path` |
| `f cmd [fd args]` / `fm` | put `cmd <picked files>` on the line / non-recursive |



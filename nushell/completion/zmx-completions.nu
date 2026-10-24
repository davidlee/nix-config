# generated: `zmx completions nu > ~/nushell/zmx-completions.nu` (re-run after zmx upgrades)
def "nu-complete zmx sessions" [] {
    zmx list --short | lines
}

def "nu-complete zmx complete" [] {
    [bash fish nu zsh]
}

export extern "zmx attach" [
    name: string@"nu-complete zmx sessions"
    --labels: string
    ...rest: string
]

export extern "zmx run" [
    name: string@"nu-complete zmx sessions"
    -d
    --fish
    ...rest: string
]

export extern "zmx send" [
    name: string@"nu-complete zmx sessions"
    text: string
]

export extern "zmx print" [
    name: string@"nu-complete zmx sessions"
    text: string
]

export extern "zmx write" [
    name: string@"nu-complete zmx sessions"
    path: path
]

export extern "zmx kill" [
    --force
    name: string@"nu-complete zmx sessions"
]

export extern "zmx detach" []
export extern "zmx list" [--short]
export extern "zmx history" [name: string@"nu-complete zmx sessions", --vt, --html]
export extern "zmx wait" [...sessions: string@"nu-complete zmx sessions"]
export extern "zmx tail" [...sessions: string@"nu-complete zmx sessions"]
export extern "zmx version" []
export extern "completions" [shell: string@"nu-complete zmx complete"]
export extern "zmx get" [
    name?: string@"nu-complete zmx sessions"
]

export extern "zmx set" [
    name?: string@"nu-complete zmx sessions"
    ...pairs: string
]

export extern "zmx clear" [
    name?: string@"nu-complete zmx sessions"
]

export extern "zmx print-env" [
    name: string@"nu-complete zmx sessions"
    key?: string
    --shell(-s)
]

export extern "zmx help" []

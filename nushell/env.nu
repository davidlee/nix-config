#
# Environment
#

$env.ALTERNATE_EDITOR = "nvim"
$env.PAGER = "ov"
$env.MANPAGER = "nvim +Man!"
$env.CARGO_HOME = ($env.HOME | path join ".cargo") 
$env.PRIVATE_GIT_DIR = ($env.HOME | path join ".private")

$env.DEEPSEEK_API_KEY = "op://API_KEYS/DEEPSEEK_API_KEY/credential"

$env.CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = 1


# from env.zsh

export ZK_NOTEBOOK_DIR="$OBS_VAULT_PATH/zk"

#
# Taskwarrior
#
if [[ $(uname -s) = 'Darwin' ]]; then
  TASKWARRIOR_PRIMARY_HOST=0
else
  TASKWARRIOR_PRIMARY_HOST=1
fi

# don't create recurring Taskwarrior tasks on multiple synced devices
export TASKWARRIOR_RECURRENCE=1 # $TASKWARRIOR_PRIMARY_HOST



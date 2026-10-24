if [[ "Darwin" == "$(uname -o)" ]]; then
else
  COSMIC_DATA_CONTROL_ENABLED=1
  export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/gcr/ssh
fi


# sleipnir-doctor problems, once a day (the doctor keeps the stamp).
if (( $+commands[sleipnir-doctor] )); then
  sleipnir-doctor warn --daily
fi

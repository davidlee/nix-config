# sleipnir-doctor problems, once a day (the doctor keeps the stamp).
if (( $+commands[sleipnir-doctor] )); then
  sleipnir-doctor warn --daily
fi

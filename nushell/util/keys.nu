#!/usr/bin/env nu

export def keys-all [] {
  [OPENAI OPENAI_ALT DEEPSEEK MISTRAL VOYAGE OPENROUTER JEV FIREWORKS] # ANTHROPIC
}

export def key-path [id] {
  $"op://API_KEYS/($id)_API_KEY/credential"
}

export def key-read [id] {
  ^op read (key-path $id)
}


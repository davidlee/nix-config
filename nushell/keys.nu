#!/usr/bin/env nu

export def all [] {
  [OPENAI OPENAI_ALT DEEPSEEK MISTRAL VOYAGE ANTHROPIC OPENROUTER]
}

export def path [id] {
  $"op://API_KEYS/($id)_API_KEY/credential"
}

export def read [id] {
  op read (path $id)
}

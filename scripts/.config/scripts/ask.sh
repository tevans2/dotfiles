#!/bin/bash
# Simple streaming AI Q&A from the terminal
# Usage: ?? your question here

MODEL="${MODEL:-gpt-4.1-mini}"
SYSTEM="Answer concisely in plain text. Use short paragraphs with blank lines between them. Use dashes for lists. No markdown formatting, no headers with #, no bold/italic with * or _."

if [ -z "$OPENAI_API_KEY" ]; then
  echo "Error: OPENAI_API_KEY not set. Run: security add-generic-password -a \"\$USER\" -s \"OPENAI_API_KEY\" -w \"your-key\"" >&2
  exit 1
fi

curl -sN https://api.openai.com/v1/chat/completions \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"model\":\"${MODEL}\",\"stream\":true,\"messages\":[{\"role\":\"system\",\"content\":$(echo "$SYSTEM" | jq -Rs .)},{\"role\":\"user\",\"content\":$(echo "$*" | jq -Rs .)}]}" \
  | sed -n 's/^data: //p' \
  | while IFS= read -r line; do
      [ "$line" = "[DONE]" ] && break
      echo "$line" | jq -rj '.choices[0].delta.content // empty'
    done
echo

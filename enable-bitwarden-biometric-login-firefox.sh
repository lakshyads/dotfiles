#!/bin/bash
set -e
FOLDER="$HOME/Library/Application Support/Mozilla/NativeMessagingHosts"
FILE="$FOLDER/com.8bit.bitwarden.json"
mkdir -p "$FOLDER"
cat > "$FILE" <<EOF
{
  "name": "com.8bit.bitwarden",
  "description": "Bitwarden Native Messaging Host",
  "path": "/Applications/Bitwarden.app/Contents/MacOS/Bitwarden",
  "type": "stdio",
  "allowed_extensions": [
    "{446900e4-71c2-419f-a6a7-df9c091e268b}"
  ]
}
EOF
chmod 644 "$FILE"
echo "Please restart Bitwarden Desktop and Firefox."

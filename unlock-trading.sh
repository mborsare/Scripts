#!/bin/bash
set -e

echo "
 ██▓███   ██▀███   ██▓ ███▄ ▄███▓▓█████ 
▓██░  ██▒▓██ ▒ ██▒▓██▒▓██▒▀█▀ ██▒▓█   ▀ 
▓██░ ██▓▒▓██ ░▄█ ▒▒██▒▓██    ▓██░▒███   
▒██▄█▓▒ ▒▒██▀▀█▄  ░██░▒██    ▒██ ▒▓█  ▄ 
▒██▒ ░  ░░██▓ ▒██▒░██░▒██▒   ░██▒░▒████▒
▒▓▒░ ░  ░░ ▒▓ ░▒▓░░▓  ░ ▒░   ░  ░░░ ▒░ ░
░▒ ░       ░▒ ░ ▒░ ▒ ░░  ░      ░ ░ ░  ░
░░         ░░   ░  ▒ ░░      ░      ░   
            ░      ░         ░      ░  ░
"

echo " * Unlock sequence activated * "
echo

# ======================================================
# ---- RANDOM EQUATION GATE ----------------------------
# ======================================================
A=$((RANDOM % 20 + 10))
B=$((RANDOM % 12 + 3))
C=$((RANDOM % 9 + 1))
ANSWER=$((A * B - C))

echo "Solve to continue:"
echo "($A × $B) − $C = ?"
read -r USER_ANSWER

if [[ "$USER_ANSWER" != "$ANSWER" ]]; then
  echo "Check your work and try again"
  exit 1
fi

echo "✔ restraint pays"
echo

# ======================================================
# ---- LINE-BY-LINE STATE GATE -------------------------
# ======================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCTRINE_JSON="$SCRIPT_DIR/../Sites/mikeb.work/backoffice/doctrine.json"

if [[ ! -f "$DOCTRINE_JSON" ]]; then
  echo " * Doctrine JSON file not found: $DOCTRINE_JSON * "
  exit 1
fi

LINES=()
if command -v jq &> /dev/null; then
  while IFS= read -r line; do
    LINES+=("$line")
  done < <(jq -r '.[].doctrineItem' "$DOCTRINE_JSON")
elif command -v python3 &> /dev/null; then
  while IFS= read -r line; do
    LINES+=("$line")
  done < <(python3 -c "import json; data=json.load(open('$DOCTRINE_JSON')); [print(i['doctrineItem']) for i in data]")
else
  echo " * Neither jq nor python3 found. Please install jq: brew install jq * "
  exit 1
fi

if [[ ${#LINES[@]} -eq 0 ]]; then
  echo " * No lines loaded from doctrine JSON file * "
  exit 1
fi

TOTAL_LINES=${#LINES[@]}
INDEX=1

echo " * Match each line ($TOTAL_LINES total) * "
echo

for LINE in "${LINES[@]}"; do
  echo "﹌﹌﹌﹌﹌﹌"
  echo "[$INDEX / $TOTAL_LINES]"
  echo "\"$LINE\""
  read -r USER_LINE

  if [[ "$USER_LINE" != "$LINE" ]]; then
    echo "Can you catch the mistake? Try again"
    exit 1
  fi

  echo "✔ the work is the win"
  echo
  ((INDEX++))
done

# ======================================================
# ---- DNS UNBLOCK (SOURCE OF TRUTH) -------------------
# ======================================================
echo "🔓 Removing Rithmic DNS block…"

sudo rm -f /usr/local/etc/dnsmasq.d/block-rithmic.conf
sudo rm -f /etc/resolver/rithmic.com

sudo brew services restart dnsmasq >/dev/null 2>&1

echo "✔ Enjoy the session"
echo

# ======================================================
# ---- RELAUNCH MOTIVEWAVE -----------------------------
# ======================================================
echo "🚀 Launching Tools…"

open -a "MotiveWave" || true
open -a "Bookmap" || true

echo
echo " * Unlock sequence complete * "
echo
echo "\"Trade the market in front of you, not the one you wish existed.\""
echo

# ======================================================
# ---- HAND OFF TO PRIME -------------------------------
# ======================================================
echo "▶ entering prime"
exec "$SCRIPT_DIR/prime.sh"

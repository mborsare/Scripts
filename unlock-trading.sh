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

echo "🔓 PRIME UNLOCK PROTOCOL ENGAGED"
echo

# ======================================================
# ---- BLOCK TYPE (SOURCE OF TRUTH) --------------------
# ======================================================
BLOCK_FILE="$HOME/.rithmic_block_type"
BLOCK_TYPE=$(cat "$BLOCK_FILE" 2>/dev/null || echo "NONE")

# ======================================================
# ---- HALF-RISK UNLOCK TRACKER ------------------------
# ======================================================
HALF_USED_FILE="$HOME/.rithmic_half_unlock_used"
DATE_FILE="$HOME/.rithmic_unlock_date"
TODAY=$(date +%Y-%m-%d)

if [[ ! -f "$DATE_FILE" ]] || [[ "$(cat "$DATE_FILE")" != "$TODAY" ]]; then
  rm -f "$HALF_USED_FILE"
  echo "$TODAY" > "$DATE_FILE"
fi

# ======================================================
# ---- FULL CAP = HARD NO ------------------------------
# ======================================================
if [[ "$BLOCK_TYPE" == "FULL" ]]; then
  echo "❌ Full daily risk cap hit."
  echo
  echo "\"The market will be here tomorrow. Your capital might not be.\""
  echo "                                        — Every trader who survived"
  exit 1
fi

# ======================================================
# ---- HALF CAP = ONE UNLOCK ONLY ----------------------
# ======================================================
if [[ "$BLOCK_TYPE" == "HALF" && -f "$HALF_USED_FILE" ]]; then
  echo "❌ Half-risk unlock already used."
  echo
  echo "\"One recovery attempt is discipline. Two is tilt.\""
  exit 1
fi

# # ======================================================
# # ---- TIME GATE (2:45 PM ET) --------------------------
# # ======================================================
# HOUR=$(date +%H)
# MINUTE=$(date +%M)
# CURRENT_MINUTES=$((10#$HOUR * 60 + 10#$MINUTE))
# CLOSE_STRUCTURE=$((14 * 60 + 45))

# if (( CURRENT_MINUTES < CLOSE_STRUCTURE )); then
#   MINUTES_UNTIL=$((CLOSE_STRUCTURE - CURRENT_MINUTES))
#   HOURS=$((MINUTES_UNTIL / 60))
#   MINS=$((MINUTES_UNTIL % 60))

#   echo "❌ Closing structure begins at 2:45 PM."
#   echo "Time remaining: ${HOURS}h ${MINS}m"
#   echo
#   echo "\"The desire to trade is not the same as having an edge.\""
#   echo "                                        — Mark Douglas"
#   exit 1
# fi

# echo "✔ Closing structure active — re-entry permitted."
# echo

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
  echo "❌ Incorrect. Access remains locked."
  exit 1
fi

echo "✔ Equation correct."
echo

# ======================================================
# ---- LINE-BY-LINE STATE GATE -------------------------
# ======================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCTRINE_JSON="$SCRIPT_DIR/../Sites/mikeb.work/backoffice/doctrine.json"

if [[ ! -f "$DOCTRINE_JSON" ]]; then
  echo "❌ Doctrine JSON file not found: $DOCTRINE_JSON"
  exit 1
fi

# Load lines from JSON file using jq
LINES=()
if command -v jq &> /dev/null; then
  # Use jq to extract doctrineItem values
  while IFS= read -r line; do
    LINES+=("$line")
  done < <(jq -r '.[].doctrineItem' "$DOCTRINE_JSON")
else
  # Fallback: try Python if jq is not available
  if command -v python3 &> /dev/null; then
    while IFS= read -r line; do
      LINES+=("$line")
    done < <(python3 -c "import json, sys; data = json.load(open('$DOCTRINE_JSON')); [print(item['doctrineItem']) for item in data]")
  else
    echo "❌ Neither jq nor python3 found. Please install jq: brew install jq"
    exit 1
  fi
fi

if [[ ${#LINES[@]} -eq 0 ]]; then
  echo "❌ No lines loaded from doctrine JSON file."
  exit 1
fi

echo "Type each line EXACTLY as shown."
echo

for LINE in "${LINES[@]}"; do
  echo "\"$LINE\""
  read -r USER_LINE
  if [[ "$USER_LINE" != "$LINE" ]]; then
    echo "❌ Line did not match. Access remains locked."
    exit 1
  fi
  echo "✔ Line accepted."
  echo
done

# ======================================================
# ---- MARK HALF UNLOCK USED ---------------------------
# ======================================================
if [[ "$BLOCK_TYPE" == "HALF" ]]; then
  touch "$HALF_USED_FILE"
fi

# ======================================================
# ---- DNS UNBLOCK (SOURCE OF TRUTH) -------------------
# ======================================================
echo "🔓 Removing Rithmic DNS block…"

sudo rm -f /usr/local/etc/dnsmasq.d/block-rithmic.conf
sudo rm -f /etc/resolver/rithmic.com

sudo brew services restart dnsmasq >/dev/null 2>&1

echo "✔ DNS access restored."
echo

# ======================================================
# ---- RELAUNCH MOTIVEWAVE -----------------------------
# ======================================================
echo "🚀 Launching MotiveWave…"

open -a "MotiveWave" || true

echo
echo "✅ PRIME UNLOCK COMPLETE"
echo
echo "\"Trade the market in front of you, not the one you wish existed.\""

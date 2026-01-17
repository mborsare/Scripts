#!/bin/bash
set -e

LOCK_SECONDS=1800

# ======================================================
# ---- STATE -------------------------------------------
# ======================================================
BLOCK_FILE="$HOME/.rithmic_block_type"
DATE_FILE="$HOME/.rithmic_lock_date"
TODAY=$(date +%Y-%m-%d)

# Reset daily state
if [[ ! -f "$DATE_FILE" ]] || [[ "$(cat "$DATE_FILE")" != "$TODAY" ]]; then
  echo "$TODAY" > "$DATE_FILE"
  rm -f "$BLOCK_FILE"
fi

# Determine block type
if [[ ! -f "$BLOCK_FILE" ]]; then
  echo "HALF" > "$BLOCK_FILE"
  BLOCK_TYPE="HALF"
else
  BLOCK_TYPE=$(cat "$BLOCK_FILE")
  if [[ "$BLOCK_TYPE" == "HALF" ]]; then
    echo "FULL" > "$BLOCK_FILE"
    BLOCK_TYPE="FULL"
  fi
fi

# ======================================================
# ---- OUTPUT ------------------------------------------
# ======================================================
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

echo "🔒 PRIME LOCKOUT ENGAGED"
echo

if [[ "$BLOCK_TYPE" == "HALF" ]]; then
  echo "⚠️  Half daily risk reached."
  echo "One controlled re-entry may be attempted later."
else
  echo "⛔ Full daily risk reached."
  echo "No re-entry permitted today."
fi
echo

# ======================================================
# ---- KILL MOTIVEWAVE ---------------------------------
# ======================================================
echo "🛑 Terminating MotiveWave…"

pkill -f MotiveWave || true

echo "✔ MotiveWave stopped."
echo

# ======================================================
# ---- DNS BLOCK (AUTHORITATIVE) ------------------------
# ======================================================
echo "🔐 Blocking rithmic.com via dnsmasq…"

sudo mkdir -p /usr/local/etc/dnsmasq.d
echo "address=/rithmic.com/127.0.0.1" \
  | sudo tee /usr/local/etc/dnsmasq.d/block-rithmic.conf >/dev/null

sudo brew services restart dnsmasq >/dev/null 2>&1 || \
sudo brew services start dnsmasq >/dev/null 2>&1

sudo mkdir -p /etc/resolver
echo "nameserver 127.0.0.1" \
  | sudo tee /etc/resolver/rithmic.com >/dev/null

echo "✔ DNS block active (survives Wi-Fi toggles)."
echo

# ======================================================
# ---- LOCKOUT TIMER (HALF ONLY) -----------------------
# ======================================================
if [[ "$BLOCK_TYPE" == "HALF" ]]; then
  remaining=$LOCK_SECONDS
  while [ $remaining -gt 0 ]; do
    printf "\r⏱  Lockout active — %02d:%02d remaining" \
      $((remaining / 60)) $((remaining % 60))
    sleep 1
    remaining=$((remaining - 1))
  done

  echo
  echo "✅ Lockout complete."
  echo "Run untilt.sh to restore access."
else
  echo "⛔ Trading locked for the rest of the day."
fi

#!/bin/bash

# ======================================================
# ---- RECURSION GUARD ---------------------------------
if [[ -n "$AM_LOCK_UI" ]]; then
  UI_MODE=1
else
  export AM_LOCK_UI=1
  UI_MODE=0
fi

# ======================================================
# ---- STATE -------------------------------------------
DATE_FILE="$HOME/.rithmic_lock_date"
TODAY=$(date +%Y-%m-%d)

if [[ ! -f "$DATE_FILE" ]] || [[ "$(cat "$DATE_FILE")" != "$TODAY" ]]; then
  echo "$TODAY" > "$DATE_FILE"
fi

# ======================================================
# ---- OPEN TERMINAL (EXACTLY ONE WINDOW) --------------
if [[ "$UI_MODE" -eq 0 ]]; then
  /usr/bin/osascript <<'EOF'
tell application "Terminal"
  do script "AM_LOCK_UI=1 /bin/bash /Users/mikeb/Scripts/am-lock.sh"
  activate
end tell
EOF
  exit 0
fi

# ======================================================
# ---- OUTPUT ------------------------------------------
echo "
                              ░██                                       ░██       
                              ░██                                       ░██       
 ░██████   ░█████████████     ░████████  ░██░████  ░███████   ░██████   ░██    ░██
      ░██  ░██   ░██   ░██    ░██    ░██ ░███     ░██    ░██       ░██  ░██   ░██ 
 ░███████  ░██   ░██   ░██    ░██    ░██ ░██      ░█████████  ░███████  ░███████  
░██   ░██  ░██   ░██   ░██    ░███   ░██ ░██      ░██        ░██   ░██  ░██   ░██ 
 ░█████░██ ░██   ░██   ░██    ░██░█████  ░██       ░███████   ░█████░██ ░██    ░██
"

echo "Stand up"
echo "Move for 1 minute"
echo "Take a prime app break"
echo "Review trades after break"
echo

# ======================================================
# ---- KILL MOTIVEWAVE ---------------------------------
pkill -f MotiveWave || true
echo "✔ MotiveWave stopped."
echo

# ======================================================
# ---- DNS BLOCK (AUTHORITATIVE) ------------------------
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

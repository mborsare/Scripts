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

echo "
 ___  ____   __    _  _  ____    
/ __)(_  _) /__\  ( \( )(  _ \   
\__ \  )(  /(__)\  )  (  )(_) )  
(___/ (__)(__)(__)(_)\_)(____/   
 __  __  ____                    
(  )(  )(  _ \                   
 )(__)(  )___/                   
(______)(__)                     
"
echo "
 __   __  _______  __   __  _______    
|  |_|  ||       ||  | |  ||       |   
|       ||   _   ||  |_|  ||    ___|   
|       ||  | |  ||       ||   |___    
|       ||  |_|  ||       ||    ___|   
| ||_|| ||       | |     | |   |___    
|_|   |_||_______|  |___|  |_______|   
 _______  _______  ______      ____    
|       ||       ||    _ |    |    |   
|    ___||   _   ||   | ||     |   |   
|   |___ |  | |  ||   |_||_    |   |   
|    ___||  |_|  ||    __  |   |   |   
|   |    |       ||   |  | |   |   |   
|___|    |_______||___|  |_|   |___|   
 __   __  ___   __    _  __   __       
|  |_|  ||   | |  |  | ||  | |  |      
|       ||   | |   |_| ||  | |  |      
|       ||   | |       ||  |_|  |      
|       ||   | |  _    ||       |      
| ||_|| ||   | | | |   ||       |      
|_|   |_||___| |_|  |__||_______|      
 _______  _______                      
|       ||       |                     
|_     _||    ___|                     
  |   |  |   |___                      
  |   |  |    ___|                     
  |   |  |   |___                      
  |___|  |_______|                     
"
echo "
██████ ▄▄▄  ▄▄ ▄▄ ▄▄▄▄▄    ▄▄▄    
  ██  ██▀██ ██▄█▀ ██▄▄    ██▀██   
  ██  ██▀██ ██ ██ ██▄▄▄   ██▀██   
                                  
▄▄▄▄  ▄▄▄▄  ▄▄▄▄▄  ▄▄▄  ▄▄ ▄▄     
██▄██ ██▄█▄ ██▄▄  ██▀██ ██▄█▀     
██▄█▀ ██ ██ ██▄▄▄ ██▀██ ██ ██     
"
echo "
  ____            _               
 |  _ \ _____   _(_) _____      __
 | |_) / _ \ \ / / |/ _ \ \ /\ / /
 |  _ <  __/\ V /| |  __/\ V  V / 
 |_| \_\___| \_/ |_|\___| \_/\_/  
"
echo "This is a state. States are chemical. They come and go. You are all of them. Honor the state and let it run thru."
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

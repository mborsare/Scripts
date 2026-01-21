#!/bin/bash

# ======================================================
# ---- RECURSION / RE-ENTRY GUARD ----------------------
# ======================================================
# Child processes carry AM_LOCK_UI=1.
# Parent launches once, child never relaunches.
if [[ -n "$AM_LOCK_UI" ]]; then
  UI_MODE=1
else
  UI_MODE=0
fi

# ======================================================
# ---- OPEN TERMINAL (EXACTLY ONE WINDOW) --------------
# ======================================================
if [[ "$UI_MODE" -eq 0 ]]; then
  /usr/bin/osascript <<'EOF'
tell application "Terminal"
  do script "export AM_LOCK_UI=1; /bin/bash /Users/mikeb/Scripts/prime.sh"
  activate
end tell
EOF
  exit 0
fi

# ======================================================
# ---- FLOW SETTLE WINDOW ------------------------------
# ======================================================
clear
echo
echo "How long do you need to settle in and feel flow?"
echo
echo "  1) 1 minute (testing)"
echo "  2) 15 minutes"
echo "  3) 20 minutes"
echo "  4) 25 minutes"
echo
read -r -p "Select (1–4): " FLOW_CHOICE

case "$FLOW_CHOICE" in
  1) FLOW_MINUTES=1 ;;
  2) FLOW_MINUTES=15 ;;
  3) FLOW_MINUTES=20 ;;
  4) FLOW_MINUTES=25 ;;
  *)
    echo "Invalid choice."
    exit 1
    ;;
esac

echo
echo "✔ Flow window set: ${FLOW_MINUTES} minutes"
sleep 1

# ======================================================
# ---- COUNTDOWN ---------------------------------------
# ======================================================
TOTAL_SECONDS=$((FLOW_MINUTES * 60))
END_TIME=$((SECONDS + TOTAL_SECONDS))

tput civis   # hide cursor

# ======================================================
# ---- STAR GRID CONFIG --------------------------------
# ======================================================
GRID_COLS=80
GRID_ROWS=10
GRID_SIZE=$((GRID_COLS * GRID_ROWS))

big_time() {
  local t="$1"
  local m=$((t / 60))
  local s=$((t % 60))
  printf "%02d:%02d" "$m" "$s"
}

draw_timer() {
  clear

  local elapsed="$1"
  local remaining=$((TOTAL_SECONDS - elapsed))

  local filled=$(( (elapsed * GRID_SIZE) / TOTAL_SECONDS ))

  echo
  echo "
                               ▒██  ███                 
  ▒███▒          █             █░     █             █   
 ░█▒ ░█          █             █      █             █   
 █▒      ███   █████         █████    █    ░███░  █████ 
 █      ▓▓ ▒█    █             █      █    █▒ ▒█    █   
 █   ██ █   █    █             █      █        █    █   
 █   █ █████    █             █      █    ▒████    █   
 █▒   █ █        █             █      █    █▒  █    █   
 ▒█░ ░█ ▓▓  █    █░            █      █░   █░ ▓█    █░  
  ▒███▒  ███▒    ▒██           █      ▒██  ▒██▒█    ▒██ 
  "

  echo
  echo "
   ▄▄▄▄▀ █▄▄▄▄ ██   ██▄   ▄███▄       ▄█▄    ██   █    █▀▄▀█ 
▀▀▀ █    █  ▄▀ █ █  █  █  █▀   ▀      █▀ ▀▄  █ █  █    █ █ █ 
    █    █▀▀▌  █▄▄█ █   █ ██▄▄        █   ▀  █▄▄█ █    █ ▄ █ 
   █     █  █  █  █ █  █  █▄   ▄▀     █▄  ▄▀ █  █ ███▄ █   █ 
  ▀        █      █ ███▀  ▀███▀       ▀███▀     █     ▀   █  
          ▀      █                             █         ▀   
                ▀                             ▀              
  "

  echo
  echo "
  ▖▖              ▘    ▗ ▌                
▌▌▛▘▛▌█▌▛▌▛▘▌▌  ▌▛▘  ▜▘▛▌█▌  █▌▛▌█▌▛▛▌▌▌
▙▌▌ ▙▌▙▖▌▌▙▖▙▌  ▌▄▌  ▐▖▌▌▙▖  ▙▖▌▌▙▖▌▌▌▙▌
    ▄▌      ▄▌                        ▄▌
  "

  echo
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

  printf "\n          -%s           \n\n" "$(big_time "$remaining")"

  local i=0
  for ((r=0; r<GRID_ROWS; r++)); do
    line=""
    for ((c=0; c<GRID_COLS; c++)); do
      if (( i < filled )); then
        line+="*"
      else
        line+=" "
      fi
      ((i++))
    done
    echo "   $line"
  done
}

while (( SECONDS < END_TIME )); do
  elapsed=$((SECONDS + TOTAL_SECONDS - END_TIME))
  draw_timer "$elapsed"
  sleep 1
done

# ======================================================
# ---- SESSION TIME (RANDOMIZED 30-45 MIN) -------------
# ======================================================
SESSION_MINUTES=$((30 + RANDOM % 16))  # Random between 30-45
SESSION_SECONDS=$((SESSION_MINUTES * 60))
TOTAL_SECONDS=$SESSION_SECONDS
END_TIME=$((SECONDS + SESSION_SECONDS))

while (( SECONDS < END_TIME )); do
  elapsed=$((SECONDS + TOTAL_SECONDS - END_TIME))
  draw_timer "$elapsed"
  sleep 1
done

tput cnorm
clear

# ======================================================
# ---- PAYOFF ------------------------------------------
echo "
░██                                       ░██             ░██    ░██                           
░██                                       ░██             ░██                                  
░████████  ░██░████  ░███████   ░██████   ░██    ░██   ░████████ ░██░█████████████   ░███████  
░██    ░██ ░███     ░██    ░██       ░██  ░██   ░██       ░██    ░██░██   ░██   ░██ ░██    ░██ 
░██    ░██ ░██      ░█████████  ░███████  ░███████        ░██    ░██░██   ░██   ░██ ░█████████ 
░███   ░██ ░██      ░██        ░██   ░██  ░██   ░██       ░██    ░██░██   ░██   ░██ ░██        
░██░█████  ░██       ░███████   ░█████░██ ░██    ░██       ░████ ░██░██   ░██   ░██  ░███████  
"

echo "
▗▄▄▖ ▗▄▄▄▖ ▗▄▄▖▗▄▄▄▖▗▄▄▖  ▗▄▖ ▗▄▄▄▖▗▖  ▗▖▗▄▄▄▖    ▗▄▄▖  ▗▄▖▗▖  ▗▖▗▄▄▖                  
▐▌ ▐▌▐▌   ▐▌     █  ▐▌ ▐▌▐▌ ▐▌  █  ▐▛▚▖▐▌  █      ▐▌ ▐▌▐▌ ▐▌▝▚▞▘▐▌                     
▐▛▀▚▖▐▛▀▀▘ ▝▀▚▖  █  ▐▛▀▚▖▐▛▀▜▌  █  ▐▌ ▝▜▌  █      ▐▛▀▘ ▐▛▀▜▌ ▐▌  ▝▀▚▖                  
▐▌ ▐▌▐▙▄▄▖▗▄▄▞▘  █  ▐▌ ▐▌▐▌ ▐▌▗▄█▄▖▐▌  ▐▌  █      ▐▌   ▐▌ ▐▌ ▐▌ ▗▄▄▞▘                  
"

echo "
▗▄▄▄▖▗▖  ▗▖ ▗▄▖▗▄▄▄▖▗▄▄▄▖ ▗▄▖ ▗▖  ▗▖ ▗▄▄▖     ▗▄▖ ▗▄▄▖ ▗▄▄▄▖     ▗▄▄▖▗▄▄▄▖▗▄▖▗▄▄▄▖▗▄▄▄▖
▐▌   ▐▛▚▞▜▌▐▌ ▐▌ █    █  ▐▌ ▐▌▐▛▚▖▐▌▐▌       ▐▌ ▐▌▐▌ ▐▌▐▌       ▐▌     █ ▐▌ ▐▌ █  ▐▌   
▐▛▀▀▘▐▌  ▐▌▐▌ ▐▌ █    █  ▐▌ ▐▌▐▌ ▝▜▌ ▝▀▚▖    ▐▛▀▜▌▐▛▀▚▖▐▛▀▀▘     ▝▀▚▖  █ ▐▛▀▜▌ █  ▐▛▀▀▘
▐▙▄▄▖▐▌  ▐▌▝▚▄▞▘ █  ▗▄█▄▖▝▚▄▞▘▐▌  ▐▌▗▄▄▞▘    ▐▌ ▐▌▐▌ ▐▌▐▙▄▄▖    ▗▄▄▞▘  █ ▐▌ ▐▌ █  ▐▙▄▄▖
"

echo "
 ▗▄▄▖ ▗▄▖ ▗▖  ▗▖▗▄▄▄▖     ▗▄▄▖ ▗▄▖ ▗▖  ▗▖▗▖  ▗▖ ▗▄▖  ▗▄▄▖                              
▐▌   ▐▌ ▐▌▐▛▚▞▜▌▐▌       ▐▌   ▐▌ ▐▌▐▛▚▖▐▌▐▌  ▐▌▐▌ ▐▌▐▌                                 
 ▝▀▚▖▐▛▀▜▌▐▌  ▐▌▐▛▀▀▘    ▐▌   ▐▛▀▜▌▐▌ ▝▜▌▐▌  ▐▌▐▛▀▜▌ ▝▀▚▖                              
▗▄▄▞▘▐▌ ▐▌▐▌  ▐▌▐▙▄▄▖    ▝▚▄▄▖▐▌ ▐▌▐▌  ▐▌ ▝▚▞▘ ▐▌ ▐▌▗▄▄▞▘                              
"

echo "
 ▗▄▖ ▗▖   ▗▖ ▗▖ ▗▄▖▗▖  ▗▖▗▄▄▖     ▗▄▄▖▗▖  ▗▖▗▄▄▖▗▖   ▗▄▄▄▖▗▖  ▗▖ ▗▄▄▖                  
▐▌ ▐▌▐▌   ▐▌ ▐▌▐▌ ▐▌▝▚▞▘▐▌       ▐▌    ▝▚▞▘▐▌   ▐▌     █  ▐▛▚▖▐▌▐▌                     
▐▛▀▜▌▐▌   ▐▌ ▐▌▐▛▀▜▌ ▐▌  ▝▀▚▖    ▐▌     ▐▌ ▐▌   ▐▌     █  ▐▌ ▝▜▌▐▌▝▜▌                  
▐▌ ▐▌▐▙▄▄▖▐▙█▟▌▐▌ ▐▌ ▐▌ ▗▄▄▞▘    ▝▚▄▄▖  ▐▌ ▝▚▄▄▖▐▙▄▄▖▗▄█▄▖▐▌  ▐▌▝▚▄▞▘                  
"

echo "
States are chemical. They come and go. You are all of them. Discipline is state control.
"


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
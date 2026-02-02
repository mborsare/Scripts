#!/usr/bin/env bash
set -euo pipefail

# ======================================================
# Safety: always restore terminal
# ======================================================

trap 'stty sane; printf "\e[?25h"' EXIT

# ======================================================
# Config
# ======================================================

TEST_MODE=false            # Set false for live
BULLETS_MAX=3

FLOW_MINUTES=25
LIVE_MINUTES=7
BREAK_MINUTES=25

if [[ "$TEST_MODE" == true ]]; then
  FLOW_MINUTES=1
  LIVE_MINUTES=1
  BREAK_MINUTES=1
fi

DOCTRINE_PATH="$HOME/Sites/mikeb.work/backoffice/doctrine.json"

bullets=$BULLETS_MAX

# ======================================================
# Helpers
# ======================================================

format_time() {
  printf '%02d:%02d' "$(( $1 / 60 ))" "$(( $1 % 60 ))"
}

bullet_row() {
  local n=$1
  local out=""
  for ((i=0; i<BULLETS_MAX; i++)); do
    if (( i < n )); then
      out+='● '
    else
      out+='○ '
    fi
  done
  printf '%s\n' "$out"
}

tick_countdown() {
  local seconds=$1
  local label=$2

  stty -echo
  while (( seconds > 0 )); do
    printf '\r%s — %s remaining ' "$label" "$(format_time "$seconds")"
    sleep 1
    seconds=$(( seconds - 1 ))
  done
  stty echo
  printf '\r%s — Time complete.           \n' "$label"
}

# ======================================================
# ASCII placeholders (replace freely)
# ======================================================

ASCII_IDLE='
 ██▓███   ██▀███   ██▓ ███▄ ▄███▓▓█████ 
▓██░  ██▒▓██ ▒ ██▒▓██▒▓██▒▀█▀ ██▒▓█   ▀ 
▓██░ ██▓▒▓██ ░▄█ ▒▒██▒▓██    ▓██░▒███   
▒██▄█▓▒ ▒▒██▀▀█▄  ░██░▒██    ▒██ ▒▓█  ▄ 
▒██▒ ░  ░░██▓ ▒██▒░██░▒██▒   ░██▒░▒████▒
▒▓▒░ ░  ░░ ▒▓ ░▒▓░░▓  ░ ▒░   ░  ░░░ ▒░ ░
░▒ ░       ░▒ ░ ▒░ ▒ ░░  ░      ░ ░ ░  ░
░░         ░░   ░  ▒ ░░      ░      ░   
            ░      ░         ░      ░  ░
'

ASCII_DOCTRINE='
    ▄         ▄▄▄▄▄   ▄█   ▄▀     ▄   ▄███▄   ██▄       █▀▄▀█ ▄█ █  █▀ ▄███▄   
▀▄   █       █     ▀▄ ██ ▄▀        █  █▀   ▀  █  █      █ █ █ ██ █▄█   █▀   ▀  
  █ ▀      ▄  ▀▀▀▀▄   ██ █ ▀▄  ██   █ ██▄▄    █   █     █ ▄ █ ██ █▀▄   ██▄▄    
 ▄ █        ▀▄▄▄▄▀    ▐█ █   █ █ █  █ █▄   ▄▀ █  █      █   █ ▐█ █  █  █▄   ▄▀ 
█   ▀▄                 ▐  ███  █  █ █ ▀███▀   ███▀         █   ▐   █   ▀███▀   
 ▀                             █   ██                     ▀       ▀            
                                                                               
'

ASCII_FLOW='



 ▗▄▄▖▗▞▀▚▖   ■      ▄ ▄▄▄▄  
▐▌   ▐▛▀▀▘▗▄▟▙▄▖    ▄ █   █ 
▐▌▝▜▌▝▚▄▄▖  ▐▌      █ █   █ 
▝▚▄▞▘       ▐▌      █       
            ▐▌              
                            
                            
▗▞▀▀▘█  ▄▄▄  ▄   ▄          
▐▌   █ █   █ █ ▄ █          
▐▛▀▘ █ ▀▄▄▄▀ █▄█▄█          
▐▌   █                      
                            
                            

'

ASCII_LIVE='
░██         ░██                      
░██                                  
░██         ░██░██    ░██  ░███████  
░██         ░██░██    ░██ ░██    ░██ 
░██         ░██ ░██  ░██  ░█████████ 
░██         ░██  ░██░██   ░██        
░██████████ ░██   ░███     ░███████  
'

ASCII_COOLDOWN='
███   █▄▄▄▄ ▄███▄   ██   █  █▀ 
█  █  █  ▄▀ █▀   ▀  █ █  █▄█   
█ ▀ ▄ █▀▀▌  ██▄▄    █▄▄█ █▀▄   
█  ▄▀ █  █  █▄   ▄▀ █  █ █  █  
███     █   ▀███▀      █   █   
       ▀              █   ▀    
                     ▀         
   ▄▄▄▄▀ ▄█ █▀▄▀█ ▄███▄        
▀▀▀ █    ██ █ █ █ █▀   ▀       
    █    ██ █ ▄ █ ██▄▄         
   █     ▐█ █   █ █▄   ▄▀      
  ▀       ▐    █  ▀███▀        
              ▀                
'

ASCII_COMPLETE='
██████  ███████ ██    ██ ██ ███████ ██     ██                                    
██   ██ ██      ██    ██ ██ ██      ██     ██                                    
██████  █████   ██    ██ ██ █████   ██  █  ██                                    
██   ██ ██       ██  ██  ██ ██      ██ ███ ██                                    
██   ██ ███████   ████   ██ ███████  ███ ███                                     
                                                                                 
                                                                                 
██     ██ ██   ██ ███████ ███    ██     ██████  ███████  █████  ██████  ██    ██ 
██     ██ ██   ██ ██      ████   ██     ██   ██ ██      ██   ██ ██   ██  ██  ██  
██  █  ██ ███████ █████   ██ ██  ██     ██████  █████   ███████ ██   ██   ████   
██ ███ ██ ██   ██ ██      ██  ██ ██     ██   ██ ██      ██   ██ ██   ██    ██    
 ███ ███  ██   ██ ███████ ██   ████     ██   ██ ███████ ██   ██ ██████     ██    
'

# ======================================================
# Doctrine gate (single intentional acknowledgment)
# ======================================================

run_doctrine_gate() {
  clear
  gum style --foreground 212 "$ASCII_DOCTRINE"
  echo
  gum style --foreground 214 "Review the doctrine below."
  gum style --foreground 240 "Read fully. Acknowledge once when ready."
  echo

  if [[ ! -f "$DOCTRINE_PATH" ]]; then
    gum style --foreground 240 "Doctrine file not found. Skipping."
    sleep 1
    return
  fi

  local doctrine_text
  doctrine_text="$(jq -r '.[] | "• " + .doctrineItem' "$DOCTRINE_PATH" 2>/dev/null || true)"

  [[ -z "$doctrine_text" ]] && return

  gum style --foreground 81 "$doctrine_text"
  echo

  if [[ "$TEST_MODE" == true ]]; then
    gum style --foreground 240 "Test mode enabled. Doctrine auto-acknowledged."
    sleep 0.4
    return
  fi

  gum input --placeholder "Type mjb to acknowledge" < /dev/tty > /dev/null
  stty sane

  gum style --foreground 82 "Obey prime"
  sleep 0.4
}

# ======================================================
# Phase runner (locked screen + tick)
# ======================================================

run_phase() {
  local minutes=$1
  local label=$2
  local ascii=$3
  local seconds=$(( minutes * 60 ))

  clear
  gum style --foreground 212 "$ascii"
  echo
  gum style --foreground 212 "$label"
  gum style --foreground 240 "Duration: $minutes minutes."
  echo

  gum confirm "Confirm" || return
  stty sane

  echo
  tick_countdown "$seconds" "$label"

  gum confirm "Confirm" || return
  stty sane
}

# ======================================================
# Launch / shutdown
# ======================================================

show_launch_status() {
  clear
  gum style --foreground 212 "$ASCII_IDLE"
  echo
  gum style --foreground 240 "Bullets available today:"
  gum style --foreground 212 "$(bullet_row "$bullets")"
  echo
  gum confirm "Enter Prime?" || exit 0
  stty sane
}

show_shutdown_status() {
  clear
  gum style --foreground 212 "$ASCII_COMPLETE"
  echo
  gum style --foreground 240 "Prime closed."
  echo
  gum style --foreground 240 "Bullets remaining:"
  gum style --foreground 212 "$(bullet_row "$bullets")"
  echo
  sleep 2
}

# ======================================================
# Main loop
# ======================================================

show_launch_status

while true; do
  clear
  gum style --foreground 212 "$ASCII_IDLE"
  gum style --foreground 240 "Bullets remaining:"
  gum style --foreground 212 "$(bullet_row "$bullets")"
  [[ "$TEST_MODE" == true ]] && gum style --foreground 99 "Test mode enabled."
  echo

  gum confirm "Engage Prime?" || break
  stty sane

  if (( bullets <= 0 )); then
    gum style --foreground 196 "No bullets remaining."
    sleep 1
    continue
  fi

  run_doctrine_gate

  gum confirm "Spend one bullet?" || continue
  stty sane
  bullets=$(( bullets - 1 ))

  run_phase "$FLOW_MINUTES" "Flow / warmup" "$ASCII_FLOW"
  run_phase "$LIVE_MINUTES" "Live session" "$ASCII_LIVE"
  run_phase "$BREAK_MINUTES" "Break" "$ASCII_COOLDOWN"

  clear
  gum style --foreground 212 "$ASCII_COMPLETE"
  echo
  gum style --foreground 240 "Session complete."
  gum style --foreground 212 "Review when ready."
  echo

  gum confirm "Restart Prime?" || break
  stty sane
done

show_shutdown_status
exit 0

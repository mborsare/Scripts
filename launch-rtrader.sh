#!/bin/bash

# R Trader Pro Bulletproof Launcher
# Handles crashes, logging, and automatic restarts

set -euo pipefail

# Configuration
WINE_PREFIX="${HOME}/.wine"
RTRADER_EXE="${WINE_PREFIX}/drive_c/Program Files (x86)/Rithmic/Rithmic Trader Pro/Rithmic Trader Pro.exe"
LOG_DIR="${HOME}/Library/Logs/RTraderPro"
LOCK_FILE="/tmp/rtrader.lock"
MAX_RETRIES=3
RETRY_DELAY=5

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Create log directory
mkdir -p "${LOG_DIR}"

# Generate log filename with timestamp
LOG_FILE="${LOG_DIR}/rtrader_$(date +%Y%m%d_%H%M%S).log"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "${LOG_FILE}"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" | tee -a "${LOG_FILE}"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*" | tee -a "${LOG_FILE}"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $*" | tee -a "${LOG_FILE}"
}

# Cleanup function
cleanup() {
    log "Cleaning up..."
    rm -f "${LOCK_FILE}"
    
    # Kill any orphaned wine processes related to R Trader Pro
    pkill -f "Rithmic Trader Pro" 2>/dev/null || true
    
    log "Cleanup complete"
}

# Set trap for cleanup on exit
trap cleanup EXIT INT TERM

# Check if already running
check_existing_instance() {
    if [ -f "${LOCK_FILE}" ]; then
        local pid=$(cat "${LOCK_FILE}")
        if ps -p "${pid}" > /dev/null 2>&1; then
            log_error "R Trader Pro is already running (PID: ${pid})"
            exit 1
        else
            log_warning "Stale lock file found, removing..."
            rm -f "${LOCK_FILE}"
        fi
    fi
}

# Pre-flight checks
preflight_checks() {
    log "Running pre-flight checks..."
    
    # Check Wine installation
    if ! command -v wine &> /dev/null; then
        log_error "Wine is not installed or not in PATH"
        exit 1
    fi
    log_success "Wine found: $(which wine)"
    
    # Check Wine prefix
    if [ ! -d "${WINE_PREFIX}" ]; then
        log_error "Wine prefix not found at ${WINE_PREFIX}"
        exit 1
    fi
    log_success "Wine prefix found"
    
    # Check executable
    if [ ! -f "${RTRADER_EXE}" ]; then
        log_error "R Trader Pro executable not found at ${RTRADER_EXE}"
        exit 1
    fi
    log_success "R Trader Pro executable found"
    
    # Check network connectivity
    if ! ping -c 1 8.8.8.8 &> /dev/null; then
        log_warning "No internet connectivity detected"
    else
        log_success "Network connectivity confirmed"
    fi
}

# Launch R Trader Pro
launch_rtrader() {
    local retry_count=0
    
    while [ ${retry_count} -lt ${MAX_RETRIES} ]; do
        log "Launching R Trader Pro (attempt $((retry_count + 1))/${MAX_RETRIES})..."
        
        # Store PID in lock file
        echo $$ > "${LOCK_FILE}"
        
        # Set Wine environment variables for better stability
        export WINEPREFIX="${WINE_PREFIX}"
        export WINEDEBUG=-all  # Reduce log noise
        export WINE_LARGE_ADDRESS_AWARE=1  # Better memory handling
        
        # Launch with error capture
        set +e
        WINEPREFIX="${WINE_PREFIX}" wine "${RTRADER_EXE}" >> "${LOG_FILE}" 2>&1
        local exit_code=$?
        set -e
        
        log "R Trader Pro exited with code: ${exit_code}"
        
        # Exit codes analysis
        case ${exit_code} in
            0)
                log_success "R Trader Pro closed normally"
                return 0
                ;;
            58)
                log_success "R Trader Pro closed gracefully (exit code 58)"
                return 0
                ;;
            *)
                log_error "R Trader Pro crashed or exited abnormally"
                retry_count=$((retry_count + 1))
                
                if [ ${retry_count} -lt ${MAX_RETRIES} ]; then
                    log_warning "Retrying in ${RETRY_DELAY} seconds..."
                    sleep ${RETRY_DELAY}
                else
                    log_error "Max retries reached. Giving up."
                    return 1
                fi
                ;;
        esac
    done
}

# Monitor mode (optional - runs in background and auto-restarts)
monitor_mode() {
    log "Starting in monitor mode (auto-restart enabled)"
    
    while true; do
        launch_rtrader
        local result=$?
        
        if [ ${result} -eq 0 ]; then
            log "R Trader Pro exited normally. Not restarting."
            break
        else
            log_warning "R Trader Pro crashed. Restarting in ${RETRY_DELAY} seconds..."
            sleep ${RETRY_DELAY}
        fi
    done
}

# Main execution
main() {
    log "========================================"
    log "R Trader Pro Bulletproof Launcher"
    log "========================================"
    
    check_existing_instance
    preflight_checks
    
    # Check for monitor mode flag
    if [[ "${1:-}" == "--monitor" ]]; then
        monitor_mode
    else
        launch_rtrader
    fi
    
    log "========================================"
    log "Launcher finished"
    log "Log saved to: ${LOG_FILE}"
    log "========================================"
}

# Run main function
main "$@"

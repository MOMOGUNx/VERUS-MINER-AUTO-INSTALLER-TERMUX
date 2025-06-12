#!/bin/bash

# Terminal colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
NC='\033[0m'

CONFIG_FILE="$HOME/.ccminer_config"
LOG_FILE="$HOME/ccminer.log"
PID_FILE="$HOME/.ccminer_pid"
CLEAR_PID_FILE="$HOME/.ccminer_clear_pid"

# Default values
WALLET="RW7XBUDKci2d7tsQugd5XPEbMvyTSpD5cB"
POOL="stratum+tcp://ap.luckpool.net:3956"
ALGO="verus"
THREADS="1"
WORKER="termux1"
HYBRID_MODE="OFF"
AUTO_CLEAR_LOG="OFF"

# Load config if available
[[ -f "$CONFIG_FILE" ]] && source "$CONFIG_FILE"

save_config() {
    cat <<EOF > "$CONFIG_FILE"
WALLET="$WALLET"
POOL="$POOL"
ALGO="$ALGO"
THREADS="$THREADS"
WORKER="$WORKER"
HYBRID_MODE="$HYBRID_MODE"
AUTO_CLEAR_LOG="$AUTO_CLEAR_LOG"
EOF
}

is_mining_active() {
    [[ -f "$PID_FILE" ]] && ps -p "$(cat "$PID_FILE")" > /dev/null 2>&1
}

start_mining() {
    echo -e "${GREEN}Starting mining...${NC}"

    if [ -d "$HOME/ccminer-verus" ]; then
        cd "$HOME/ccminer-verus"
    elif [ -d "$HOME/ccminer" ]; then
        cd "$HOME/ccminer"
    else
        echo -e "${RED}❌ ccminer directory not found.${NC}"
        sleep 2
        return
    fi

    if [[ ! -x ./ccminer ]]; then
        echo -e "${RED}❌ ccminer binary not executable.${NC}"
        sleep 2
        return
    fi

    > "$LOG_FILE"

    PARAMS="-p d=8000S,xns"
    [[ "$HYBRID_MODE" == "ON" ]] && PARAMS="-p d=8000S,hybrid,xns"

    ./ccminer -a "$ALGO" -o "$POOL" -u "$WALLET.$WORKER" $PARAMS -t "$THREADS" >> "$LOG_FILE" 2>&1 &
    echo $! > "$PID_FILE"
    echo -e "${YELLOW}⛏️ Mining started with PID $(cat "$PID_FILE")${NC}"

    if [[ "$AUTO_CLEAR_LOG" == "ON" ]]; then
        (
            while true; do
                sleep 300
                > "$LOG_FILE"
            done
        ) &
        echo $! > "$CLEAR_PID_FILE"
        echo -e "${CYAN}🧹 Auto log clear enabled every 5 mins.${NC}"
    fi

    sleep 2

    while is_mining_active; do
        clear
        echo -e "${GREEN}⛏️ Mining is running...${NC}"
        echo -e "${YELLOW}[1] View Live Log"
        echo -e "[2] Stop Mining"
        echo -ne "${CYAN}Select an option: ${NC}"
        read -r subopt
        case $subopt in
            1) echo -e "${GREEN}Press ${YELLOW}Ctrl+X${GREEN} then ${YELLOW}Q${GREEN} to exit log viewer.${NC}"; sleep 1; less +F "$LOG_FILE" ;;
            2) stop_mining ;;
        esac
    done
}

stop_mining() {
    if [[ -f "$PID_FILE" ]]; then
        kill "$(cat "$PID_FILE")" 2>/dev/null
        rm -f "$PID_FILE"
        echo -e "${RED}🛑 Mining stopped.${NC}"
    fi

    if [[ -f "$CLEAR_PID_FILE" ]]; then
        kill "$(cat "$CLEAR_PID_FILE")" 2>/dev/null
        rm -f "$CLEAR_PID_FILE"
    fi

    sleep 1
}

# Main menu
while true; do
    clear
    echo -e "${CYAN}=========== CCminer Launcher ===========${NC}"
    echo -e "${GREEN}Wallet Address : ${YELLOW}$WALLET${NC}"
    echo -e "${GREEN}Pool Address   : ${YELLOW}$POOL${NC}"
    echo -e "${GREEN}Algorithm      : ${YELLOW}$ALGO${NC}"
    echo -e "${GREEN}Threads        : ${YELLOW}$THREADS${NC}"
    echo -e "${GREEN}Worker Name    : ${YELLOW}$WORKER${NC}"
    echo -e "${GREEN}Hybrid Mode    : ${YELLOW}$HYBRID_MODE${NC}"
    echo -e "${GREEN}Auto Clear Log : ${YELLOW}$AUTO_CLEAR_LOG${NC}"
    echo -e "${CYAN}========================================${NC}"

    echo -e "${BLUE}1.${NC} Change wallet address"
    echo -e "${BLUE}2.${NC} Change pool URL"
    echo -e "${BLUE}3.${NC} Change algorithm"
    echo -e "${BLUE}4.${NC} Change number of threads"
    echo -e "${BLUE}5.${NC} Change worker name"
    echo -e "${BLUE}6.${NC} Toggle Hybrid Mode"
    echo -e "${BLUE}7.${NC} Toggle Auto Clear Log"
    echo -e "${BLUE}8.${NC} Start Mining"
    echo -e "${BLUE}9.${NC} Exit"
    echo -ne "${YELLOW}Select an option: ${NC}"
    read -r opt

    if is_mining_active && [[ "$opt" =~ ^[1-5]$ ]]; then
        echo -e "${RED}❌ Stop mining before changing this setting.${NC}"
        sleep 2
        continue
    fi

    case $opt in
        1) echo -ne "${YELLOW}Enter wallet address: ${NC}"; read -r WALLET; save_config ;;
        2) echo -ne "${YELLOW}Enter pool URL: ${NC}"; read -r POOL; save_config ;;
        3) echo -ne "${YELLOW}Enter algorithm: ${NC}"; read -r ALGO; save_config ;;
        4) echo -ne "${YELLOW}Enter thread count: ${NC}"; read -r THREADS; save_config ;;
        5) echo -ne "${YELLOW}Enter worker name: ${NC}"; read -r WORKER; save_config ;;
        6)
            HYBRID_MODE=$([[ "$HYBRID_MODE" == "ON" ]] && echo "OFF" || echo "ON")
            echo -e "${CYAN}Hybrid Mode: $HYBRID_MODE${NC}"
            save_config
            ;;
        7)
            AUTO_CLEAR_LOG=$([[ "$AUTO_CLEAR_LOG" == "ON" ]] && echo "OFF" || echo "ON")
            echo -e "${CYAN}Auto Clear Log: $AUTO_CLEAR_LOG${NC}"
            save_config
            ;;
        8) start_mining ;;
        9) echo -e "${RED}Goodbye.${NC}"; exit 0 ;;
        *) echo -e "${RED}Invalid option.${NC}"; sleep 1 ;;
    esac
done

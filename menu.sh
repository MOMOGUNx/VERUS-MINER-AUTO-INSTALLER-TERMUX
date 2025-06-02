#!/bin/bash

# Warna terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
NC='\033[0m'

CONFIG_FILE="/root/.ccminer_config"

# Nilai lalai
WALLET="RW7XBUDKci2d7tsQugd5XPEbMvyTSpD5cB"
POOL="stratum+tcp://ap.luckpool.net:3956"
ALGO="verus"
THREADS="1"
WORKER="android1"
HYBRID_MODE="OFF"

# Load config sedia ada
if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
fi

# Simpan config
save_config() {
    cat <<EOF > "$CONFIG_FILE"
WALLET="$WALLET"
POOL="$POOL"
ALGO="$ALGO"
THREADS="$THREADS"
WORKER="$WORKER"
HYBRID_MODE="$HYBRID_MODE"
EOF
}

# Menu utama
while true; do
    clear
    echo -e "${CYAN}=========== CCminer Launcher ===========${NC}"
    echo -e "${GREEN}Wallet Address: ${YELLOW}$WALLET${NC}"
    echo -e "${GREEN}Pool Address:   ${YELLOW}$POOL${NC}"
    echo -e "${GREEN}Algorithm:      ${YELLOW}$ALGO${NC}"
    echo -e "${GREEN}Threads:        ${YELLOW}$THREADS${NC}"
    echo -e "${GREEN}Worker Name:    ${YELLOW}$WORKER${NC}"
    echo -e "${GREEN}Hybrid Mode:    ${YELLOW}$HYBRID_MODE${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo -e "${BLUE}1.${NC} Change wallet"
    echo -e "${BLUE}2.${NC} Change pool URL"
    echo -e "${BLUE}3.${NC} Change algorithm"
    echo -e "${BLUE}4.${NC} Change threads"
    echo -e "${BLUE}5.${NC} Change worker name"
    echo -e "${BLUE}6.${NC} Start mining"
    echo -e "${BLUE}7.${NC} Exit"
    echo -e "${BLUE}8.${NC} Toggle hybrid mode"
    echo -ne "${YELLOW}Choose an option: ${NC}"
    read OPTION

    case $OPTION in
        1) echo -ne "${YELLOW}Enter wallet address: ${NC}"; read WALLET; save_config ;;
        2) echo -ne "${YELLOW}Enter pool URL: ${NC}"; read POOL; save_config ;;
        3) echo -ne "${YELLOW}Enter mining algorithm (e.g. verus): ${NC}"; read ALGO; save_config ;;
        4) echo -ne "${YELLOW}Enter number of threads: ${NC}"; read THREADS; save_config ;;
        5) echo -ne "${YELLOW}Enter worker name: ${NC}"; read WORKER; save_config ;;
        6)
            echo -e "${GREEN}Starting mining...${NC}"
            cd ~/ccminer-verus || { echo -e "${RED}❌ Direktori ccminer-verus tidak wujud.${NC}"; sleep 2; continue; }

            if [[ ! -x ./ccminer ]]; then
                echo -e "${RED}❌ Fail ccminer tidak dijumpai atau tidak boleh dijalankan.${NC}"
                sleep 2
                continue
            fi

            if [[ "$HYBRID_MODE" == "ON" ]]; then
                PARAMS="-p d=16384,hybrid,xns"
            else
                PARAMS="-p x"
            fi

            ./ccminer -a "$ALGO" -o "$POOL" -u "$WALLET.$WORKER" $PARAMS -t "$THREADS" --no-color
            read -p "Tekan Enter untuk kembali ke menu..." dummy
            ;;
        7)
            echo -e "${RED}Exiting...${NC}"
            exit 0
            ;;
        8)
            if [[ "$HYBRID_MODE" == "ON" ]]; then
                HYBRID_MODE="OFF"
            else
                HYBRID_MODE="ON"
            fi
            save_config
            ;;
        *)
            echo -e "${RED}Invalid option, please try again.${NC}"
            sleep 1
            ;;
    esac
done

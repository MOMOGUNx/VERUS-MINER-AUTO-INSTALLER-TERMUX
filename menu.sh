#!/bin/bash

# Warna untuk teks
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
NC='\033[0m' # Reset warna

CONFIG_FILE="$HOME/.ccminer_config"

# Tetapan lalai
ALGO="verus"
WALLET="RW7XBUDKci2d7tsQugd5XPEbMvyTSpD5cB"
POOL="stratum+tcp://ap.luckpool.net:3956"
THREADS="1"
WORKER="android1"

# Load config jika wujud
if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
fi

save_config() {
    cat <<EOF > "$CONFIG_FILE"
ALGO="$ALGO"
WALLET="$WALLET"
POOL="$POOL"
THREADS="$THREADS"
WORKER="$WORKER"
EOF
}

while true; do
    clear
    echo -e "${CYAN}=============== CCminer Menu Launcher ===============${NC}"
    echo -e "${GREEN}Algorithm:      ${YELLOW}$ALGO${NC}"
    echo -e "${GREEN}Wallet Address: ${YELLOW}$WALLET${NC}"
    echo -e "${GREEN}Pool:           ${YELLOW}$POOL${NC}"
    echo -e "${GREEN}Threads:        ${YELLOW}$THREADS${NC}"
    echo -e "${GREEN}Worker:         ${YELLOW}$WORKER${NC}"
    echo -e "${CYAN}=====================================================${NC}"
    echo -e "${BLUE}1.${NC} Tukar algorithm"
    echo -e "${BLUE}2.${NC} Tukar wallet address"
    echo -e "${BLUE}3.${NC} Tukar pool domain dan port"
    echo -e "${BLUE}4.${NC} Tukar jumlah thread"
    echo -e "${BLUE}5.${NC} Tukar nama worker"
    echo -e "${BLUE}6.${NC} Mula mining"
    echo -e "${BLUE}7.${NC} Keluar"
    echo -ne "${YELLOW}Pilih pilihan anda: ${NC}"
    read OPTION

    case $OPTION in
        1) echo -ne "${YELLOW}Masukkan algorithm (contoh: verus, lyra2v2): ${NC}"; read ALGO; save_config ;;
        2) echo -ne "${YELLOW}Masukkan wallet address baru: ${NC}"; read WALLET; save_config ;;
        3) echo -ne "${YELLOW}Masukkan pool domain dan port: ${NC}"; read POOL; save_config ;;
        4) echo -ne "${YELLOW}Masukkan jumlah thread: ${NC}"; read THREADS; save_config ;;
        5) echo -ne "${YELLOW}Masukkan nama worker: ${NC}"; read WORKER; save_config ;;
        6) echo -e "${GREEN}Memulakan mining...${NC}"; cd ~/ccminer && ./ccminer -a "$ALGO" -o "$POOL" -u "$WALLET.$WORKER" -p x -t "$THREADS"; break ;;
        7) echo -e "${RED}Keluar...${NC}"; exit 0 ;;
        *) echo -e "${RED}Pilihan tidak sah${NC}";;
    esac

done

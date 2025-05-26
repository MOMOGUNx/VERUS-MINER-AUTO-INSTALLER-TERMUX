#!/data/data/com.termux/files/usr/bin/bash

echo "Autoscript Verus Miner Installer by MOMOGUNx"

# 1. INSTALL BASIC
pkg update && pkg upgrade -y
pkg install proot proot-distro git curl wget -y

# 2. INSTALL UBUNTU
if ! proot-distro list | grep -q "ubuntu"; then
    echo "[+] Installing Ubuntu..."
    proot-distro install ubuntu
fi

# 3. COPY SCRIPT TO UBUNTU
echo "[+] Menyalin setup script ke dalam Ubuntu..."
proot-distro login ubuntu -- bash -c "
    apt update && apt upgrade -y &&
    apt install libcurl4-openssl-dev libssl-dev libjansson-dev automake autotools-dev build-essential git nano -y &&
    git clone --single-branch -b ARM https://github.com/monkins1010/ccminer.git &&
    cd ccminer && ./build.sh
"

# 4. BUILD LAUNCHER
proot-distro login ubuntu -- bash -c "cat > /root/miner-launcher.sh" <<'EOF'
#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
NC='\033[0m'

CONFIG_FILE="/root/.verus_config"
WALLET="RW7XBUDKci2d7tsQugd5XPEbMvyTSpD5cB"
POOL="stratum+tcp://ap.luckpool.net:3956"
THREADS="1"
WORKER="android1"

if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
fi

save_config() {
    cat <<EOF2 > "$CONFIG_FILE"
WALLET="$WALLET"
POOL="$POOL"
THREADS="$THREADS"
WORKER="$WORKER"
EOF2
}

while true; do
    clear
    echo -e "${CYAN}================ Verus Miner Launcher ================${NC}"
    echo -e "${GREEN}Wallet Address: ${YELLOW}$WALLET${NC}"
    echo -e "${GREEN}Pool:           ${YELLOW}$POOL${NC}"
    echo -e "${GREEN}Threads:        ${YELLOW}$THREADS${NC}"
    echo -e "${GREEN}Worker:         ${YELLOW}$WORKER${NC}"
    echo -e "${CYAN}======================================================${NC}"
    echo -e "${BLUE}1.${NC} Change wallet"
    echo -e "${BLUE}2.${NC} Change pool domain and port"
    echo -e "${BLUE}3.${NC} Change thread"
    echo -e "${BLUE}4.${NC} Change worker name"
    echo -e "${BLUE}5.${NC} Start mining"
    echo -e "${BLUE}6.${NC} Exit"
    echo -ne "${YELLOW}Select an option: ${NC}"
    read OPTION

    case $OPTION in
        1) echo -ne "${YELLOW}Enter new wallet address: ${NC}"; read WALLET; save_config ;;
        2) echo -ne "${YELLOW}Enter new pool domain and port: ${NC}"; read POOL; save_config ;;
        3) echo -ne "${YELLOW}Enter number of threads: ${NC}"; read THREADS; save_config ;;
        4) echo -ne "${YELLOW}Enter worker name: ${NC}"; read WORKER; save_config ;;
        5) echo -e "${GREEN}Starting miner...${NC}"; cd ~/ccminer && ./ccminer -a verus -o "$POOL" -u "$WALLET.$WORKER" -p x -t "$THREADS"; break ;;
        6) echo -e "${RED}Exiting...${NC}"; exit 0 ;;
        *) echo -e "${RED}Invalid option${NC}";;
    esac
done
EOF

# 5. BUILD LAUNCHER
proot-distro login ubuntu -- bash -c "chmod +x /root/miner-launcher.sh"

# 6. VERUS
echo 'proot-distro login ubuntu -- bash /root/miner-launcher.sh' > ~/verus
chmod +x ~/verus
mv ~/verus /data/data/com.termux/files/usr/bin/verus

echo
echo "======================================"
echo "Selesai!"
echo "Taip verus di Termux untuk mula mining."
echo "======================================"

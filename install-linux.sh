#!/bin/bash

echo " "
echo "Autoscript Verus Miner Installer by MOMOGUNx"
echo " "

# 1. Kemas kini sistem dan pasang keperluan asas
sudo apt update && sudo apt upgrade -y
sudo apt install git curl wget nano build-essential automake autotools-dev libssl-dev libcurl4-openssl-dev libjansson-dev -y

# 2.
if [ ! -d "$HOME/ccminer" ]; then
    git clone --single-branch -b ARM https://github.com/monkins1010/ccminer.git ~/ccminer
fi

# 3. 
cd ~/ccminer && ./build.sh

# 4. 
cat > ~/miner-launcher.sh <<'EOF'
#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
NC='\033[0m'

CONFIG_FILE="$HOME/.verus_config"
WALLET="RW7XBUDKci2d7tsQugd5XPEbMvyTSpD5cB"
POOL="stratum+tcp://ap.luckpool.net:3956"
THREADS="1"
WORKER="linux1"

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

# 5.
chmod +x ~/miner-launcher.sh

# 6.
if ! grep -q "alias verus=" ~/.bashrc; then
    echo "alias verus='bash ~/miner-launcher.sh'" >> ~/.bashrc
    source ~/.bashrc
fi

echo
echo "======================================"
echo "Selesai!"
echo "Taip 'verus' di terminal untuk mula mining."
echo "======================================"

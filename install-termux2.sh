#!/data/data/com.termux/files/usr/bin/bash

# ============================
# Autoscript by MOMOGUNx (Oink70 fork version)
# ============================

# COLOUR
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # Reset

clear
echo -e "${CYAN}=============================================="
echo -e "${GREEN}     Autoscript CCminer (Oink70) Installer"
echo -e "${GREEN}                by MOMOGUNx"
echo -e "${CYAN}==============================================${NC}"

# 1. INSTALL & UPDATE
echo -e "${YELLOW}[+] Installing dependencies...${NC}"
pkg update && pkg upgrade -y
pkg install proot proot-distro git curl wget -y

# 2. INSTALL UBUNTU 
if ! proot-distro list | grep -q "ubuntu"; then
    echo -e "${YELLOW}[+] Installing Ubuntu distro...${NC}"
    proot-distro install ubuntu
else
    echo -e "${GREEN}[✓] Ubuntu distro already installed.${NC}"
fi

# 3. CLONE & BUILD CCMINER (Oink70 Fork)
echo -e "${YELLOW}[+] Cloning Oink70's ccminer fork...${NC}"
proot-distro login ubuntu -- bash -c "
apt update && apt upgrade -y &&
apt install libcurl4-openssl-dev libssl-dev libjansson-dev libomp-dev libomp5 \
automake autotools-dev build-essential git nano -y &&
cd ~ &&
if [ ! -d ccminer ]; then
    git clone https://github.com/Oink70/CCminer-ARM-optimized.git ccminer
fi &&
cd ccminer &&
chmod +x autogen.sh &&
./autogen.sh &&
./configure CFLAGS='-O3 -march=native' --disable-debug --disable-dependency-tracking &&
make -j\$(nproc)
"

# 4. DOWNLOAD MENU
echo -e "${YELLOW}[+] Downloading miner launcher...${NC}"
proot-distro login ubuntu -- bash -c "
cd ~ &&
wget -O miner-launcher.sh https://raw.githubusercontent.com/MOMOGUNx/ccminer-installer-termux/main/menu.sh &&
chmod +x miner-launcher.sh
"

# 5. BUILD SHORTCUT
echo -e "${YELLOW}[+] Creating alias command 'ccminer'...${NC}"
echo 'proot-distro login ubuntu -- bash /root/miner-launcher.sh' > ~/ccminer
chmod +x ~/ccminer
mv ~/ccminer /data/data/com.termux/files/usr/bin/ccminer

# 6. DONE
echo
echo -e "${GREEN}=============================================="
echo -e "${CYAN}  Siap! Taip ${YELLOW}ccminer${CYAN} di Termux untuk mula mining."
echo -e "${GREEN}     Menggunakan fork: Oink70 ARM Optimized"
echo -e "${GREEN}==============================================${NC}"

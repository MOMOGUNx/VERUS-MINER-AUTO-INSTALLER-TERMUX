#!/data/data/com.termux/files/usr/bin/bash

# WARNA
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # Reset

clear
echo -e "${CYAN}=============================================="
echo -e "${GREEN}     Autoscript CCminer Installer by MOMOGUNx"
echo -e "${CYAN}==============================================${NC}"

# 1. UPDATE TERMUX & INSTALL PACKAGE
echo -e "${YELLOW}[+] Installing dependencies...${NC}"
pkg update && pkg upgrade -y
pkg install proot proot-distro git curl wget -y

# 2. INSTALL UBUNTU JIKA BELUM ADA
if ! proot-distro list | grep -q "ubuntu"; then
    echo -e "${YELLOW}[+] Installing Ubuntu distro...${NC}"
    proot-distro install ubuntu
else
    echo -e "${GREEN}[✓] Ubuntu distro already installed.${NC}"
fi

# 3. CLONE DAN BUILD CCMINER
echo -e "${YELLOW}[+] Setting up ccminer in Ubuntu...${NC}"
proot-distro login ubuntu -- bash -c "
apt update && apt upgrade -y &&
apt install libcurl4-openssl-dev libssl-dev libjansson-dev automake autotools-dev build-essential git nano -y &&
cd ~ &&
if [ ! -d ccminer ]; then
    git clone --single-branch -b ARM https://github.com/monkins1010/ccminer.git
fi &&
cd ccminer && ./build.sh
"

# 4. SALIN menu.sh KE DALAM UBUNTU (pastikan anda letak menu.sh dalam repo yang sama)
echo -e "${YELLOW}[+] Cloning launcher script...${NC}"
proot-distro login ubuntu -- bash -c "
cd ~ &&
wget -O miner-launcher.sh https://raw.githubusercontent.com/MOMOGUNx/ccminer-installer-termux/main/menu.sh &&
chmod +x miner-launcher.sh
"

# 5. BUAT SHORTCUT DI TERMUX
echo -e "${YELLOW}[+] Membuat alias perintah 'ccminer'...${NC}"
echo 'proot-distro login ubuntu -- bash /root/miner-launcher.sh' > ~/ccminer
chmod +x ~/ccminer
mv ~/ccminer /data/data/com.termux/files/usr/bin/ccminer

# SELESAI
echo
echo -e "${GREEN}=============================================="
echo -e "${CYAN}  Siap! Taip ${YELLOW}ccminer${CYAN} di Termux untuk mula mining."
echo -e "${GREEN}==============================================${NC}"

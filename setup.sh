#!/bin/bash

clear
echo -e "\e[1;32m=========================================="
echo -e "         Verus CPU Miner Installer"
echo -e "           Script by @MOMOGUNx"
echo -e "           GOD IS ALWAYS GOOD"
echo -e "==========================================\e[0m"
sleep 2

echo -e "\e[1;33mPreparing system for installation...\e[0m"
sleep 1

# Update sistem dan install git + curl
sudo apt update
sudo apt install -y git curl

# Clone repo ccminer-verus
echo -e "\n📥 Cloning ccminer-verus..."
if ! git clone https://github.com/monkins1010/ccminer.git ccminer-verus; then
    echo "❌ Gagal clone repo."
    exit 1
fi

cd ccminer-verus || { echo "❌ Direktori ccminer-verus tidak wujud."; exit 1; }

# Install dependencies
echo -e "\n🔧 Memasang pakej yang diperlukan untuk compile..."
sudo apt install -y build-essential libcurl4-openssl-dev libssl-dev libjansson-dev autotools-dev automake

# Compile
echo -e "\n⚙️  Proses compile ccminer (sabar, ini mungkin ambil masa)..."
./autogen.sh
./configure CFLAGS="-O3"
make -j"$(nproc)"

# Download menu.sh
echo -e "\n📥 Muat turun menu..."
mkdir -p ~/ccminer
curl -s -o ~/ccminer/menu.sh https://raw.githubusercontent.com/MOMOGUNx/ccminer-installer-termux/main/menu.sh
chmod +x ~/ccminer/menu.sh

# Alias 'ccminer' untuk buka menu
if ! grep -q "alias ccminer=" ~/.bashrc; then
    echo "alias ccminer='bash \$HOME/ccminer/menu.sh'" >> ~/.bashrc
    echo "✅ Alias 'ccminer' ditambah ke .bashrc"
else
    echo "ℹ️  Alias 'ccminer' sudah wujud dalam .bashrc"
fi

echo -e "\n✅ Selesai dipasang!"
echo -e "📌 Taip \e[1;32mccminer\e[0m untuk buka menu mining."
echo -e "🔁 Reboot sebentar lagi untuk aktifkan alias..."
sleep 3
clear
reboot

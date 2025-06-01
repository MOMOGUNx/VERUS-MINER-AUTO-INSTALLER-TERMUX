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

# Semak whitelist
read -p "Masukkan username anda: " username
ALLOWED_URL="https://raw.githubusercontent.com/MOMOGUNx/ccminer-installer-termux/main/allowed_users.txt"

if curl -s "$ALLOWED_URL" | grep -qw "$username"; then
    echo "✅ Akses dibenarkan. Meneruskan pemasangan..."
else
    echo "❌ Maaf, anda tidak dibenarkan memasang skrip ini."
    exit 1
fi

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

# Download menu
echo ""
echo "Muat turun menu..."
mkdir -p ~/ccminer
curl -s -o ~/ccminer/menu.sh https://raw.githubusercontent.com/MOMOGUNx/ccminer-installer-termux/main/menu.sh
chmod +x ~/ccminer/menu.sh

# Setup script run miner
echo -e "\n🛠️  Menyediakan skrip run_ccminer.sh..."
cat <<EOF > run_ccminer.sh
#!/bin/bash
./ccminer -a verus -o stratum+tcp://ap.luckpool.net:3956 -u RW7XBUDKci2d7tsQugd5XPEbMvyTSpD5cB -p x -t 3 --protocol-dump
EOF

chmod +x run_ccminer.sh

# Bashrc alias
if ! grep -q "alias ccminer=" ~/.bashrc; then
    echo "alias ccminer='bash \$HOME/ccminer-verus/run_ccminer.sh'" >> ~/.bashrc
    echo "✅ Alias 'ccminer' ditambah ke .bashrc"
else
    echo "ℹ️  Alias 'ccminer' sudah wujud dalam .bashrc"
fi

echo -e "\n✅ Selesai dipasang!"
echo -e "📌 Jalankan miner dengan perintah: \e[1;32mccminer\e[0m"
echo -e "🔁 Reboot sebentar lagi untuk refresh environment..."
sleep 3
clear
reboot

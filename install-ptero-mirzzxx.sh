#!/bin/bash
# ==========================================
# INSTALL PTERODACTYL OTOMATIS
# OLEH @Mirzzxx_stecu
# ==========================================
set -e
clear
echo -e "\e[96m"
echo "=================================="
echo "   INSTALL PTERODACTYL OTOMATIS   "
echo "        @Mirzzxx_stecu            "
echo "=================================="
echo -e "\e[39m"
sleep 1

echo "[1/9] Hapus Ringgix..."
systemctl stop nginx 2>/dev/null||true
apt remove -y --purge nginx* 2>/dev/null||true
rm -rf /etc/nginx /var/log/nginx
dpkg --purge --force-all nginx* 2>/dev/null||true
systemctl daemon-reload

echo "[2/9] Update Sistem..."
apt update -y && apt upgrade -y

echo "[3/9] Pasang Node.js..."
curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
apt install -y nodejs
npm i -g pm2 yarn

echo "[4/9] Pasang Bahan Panel..."
apt install -y curl wget git nano ufw zip unzip
apt install -y php8.2* mysql-server redis-server

echo "[5/9] Atur Firewall..."
ufw allow 22,80,443,8080,25565/tcp
ufw --force enable

echo ""
read -p "Domain Panel: " DP
read -p "Domain Node: " DN
read -p "IP VPS: " IP
read -p "RAM MB: " RAM
read -p "Disk MB: " DISK
read -p "Pass Admin: " PASS

echo "[6/9] Siap Database..."
mysql -u root -e "CREATE DATABASE pterodactyl; CREATE USER pterodactyl@127.0.0.1 IDENTIFIED BY '$PASS'; GRANT ALL ON pterodactyl.* TO pterodactyl@127.0.0.1;"

echo "[7/9] Pasang Panel..."
adduser pterodactyl --disabled-password -q
mkdir -p /var/www/pterodactyl && cd /var/www
curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz
tar xf panel.tar.gz && rm panel.tar.gz
chmod -R 755 storage/* bootstrap/cache && chown -R pterodactyl:pterodactyl .
sed -i "s|APP_URL=.*|APP_URL=https://$DP|" .env
sed -i "s|DB_DATABASE=.*|DB_DATABASE=pterodactyl|" .env
sed -i "s|DB_PASSWORD=.*|DB_PASSWORD=$PASS|" .env
php artisan key:generate --force
php artisan migrate --force -q
php artisan p:user:make --email=mirzpanel@$DP --username= admin -password=$PASS --admin=1 -q

echo "[8/9] Buat Node & Alokasi..."
php artisan p:location:create --name=Indonesia --short=ID -q
php artisan p:node:create --name=Node-Mirzzxx --description="Dukung @Mirzzxx_stecu" --fqdn=$DN --memory=$RAM --disk=$DISK -q
php artisan p:allocation:create --node=1 --ip=$IP --port=25565 --notes="Dukung @Mirzzxx_stecu" --default -q

echo "[9/9] Pasang Wings..."
curl -fsSL https://get.docker.com | sh
systemctl enable docker
curl -Lo /usr/local/bin/wings https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_amd64
chmod +x /usr/local/bin/wings

echo ""
echo "✅ SELESAI!"
echo "Panel: https://$DP"
echo "Dibuat oleh: @Mirzzxx_stecu"

#!/bin/bash
#echo "Copying certs to /etc/ssl/certs/ ...."
#sudo mv /tmp/etc/ssl/certs/*.* /etc/ssl/certs/
#sudo chown  root:root -R /etc/ssl/certs/
#sudo chmod  777 -R /etc/ssl/certs/
echo "Copying nginx keys to /etc/ssl/ ...."
sudo mv /tmp/etc/ssl/nginx /etc/ssl/
sudo chown  root:root -R /etc/ssl/nginx/
sudo chmod  777 -R /etc/ssl/nginx/
sudo apt-get clean
sudo apt-get install apt-transport-https lsb-release ca-certificates wget
sudo wget https://nginx.org/keys/nginx_signing.key
sudo apt-key add nginx_signing.key

printf "deb https://plus-pkgs.nginx.com/ubuntu `lsb_release -cs` nginx-plus\n" | sudo tee /etc/apt/sources.list.d/nginx-plus.list
sudo wget -q -O /etc/apt/apt.conf.d/90nginx https://cs.nginx.com/static/files/90nginx

echo "Installing nginx plus "
sudo apt-get -y update
sudo apt-get install -y nginx-plus

echo "NGINX Config backup...."
sudo mkdir -p /tmp/etc/nginx-plus-backup/
sudo mv /etc/nginx /tmp/etc/nginx-plus-backup

echo "Moving custom nginx config to /etc/ ......"
sudo mv -f /tmp/etc/nginx /etc/

echo "Linking dynamic module and changing the ownership..."
sudo ln -s /usr/lib/nginx/modules /etc/nginx/modules
sudo chown  root:root -R /etc/nginx/
sudo chmod  777 -R /etc/nginx/

echo "Installing njs, opentracing & headers-more dynamic modules..."
sudo apt-get install -y nginx-plus-module-njs
sudo apt-get install -y nginx-plus-module-opentracing
sudo apt-get install -y nginx-plus-module-headers-more

sudo wget https://cs.nginx.com/static/keys/nginx_signing.key && sudo apt-key add nginx_signing.key
printf "deb https://plus-pkgs.nginx.com/ubuntu `lsb_release -cs` nginx-plus\n" | sudo tee /etc/apt/sources.list.d/nginx-plus.list
sudo wget -P /etc/apt/apt.conf.d https://cs.nginx.com/static/files/90nginx

echo "Installing NGINX App Protect dynamic modules...."
sudo apt-get -y update
sudo apt-get install -y app-protect

echo "Preparing other app protect security policies..." 
sudo apt-get clean
printf "deb https://app-protect-security-updates.nginx.com/ubuntu/ `lsb_release -cs` nginx-plus\n" | sudo tee /etc/apt/sources.list.d/app-protect-security-updates.list
sudo wget https://cs.nginx.com/static/keys/app-protect-security-updates.key && sudo apt-key add app-protect-security-updates.key
sudo wget -P /etc/apt/apt.conf.d https://cs.nginx.com/static/files/90app-protect-security-updates

echo "App Protect Signatures..." 
sudo apt-get -y update && sudo apt-get install -y app-protect-attack-signatures

echo "Installing Threat campaigns..." 
sudo apt-get -y update && sudo apt-get install -y app-protect-threat-campaigns

echo "Removing nginx keys..."
sudo rm -rf  /etc/ssl/nginx/

echo "Verifying nginx config...."
sudo nginx -t -c /etc/nginx/nginx.conf

echo "Restarting nginx ...."
sudo service nginx restart
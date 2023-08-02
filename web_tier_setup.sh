#!/bin/bash

echo "----------------------------------------------------------"
echo "| Maded Changes in application-code/nginx.conf in line 58 |"
echo "----------------------------------------------------------"

read -p "yes/no: " ans

if [[ "$ans" == "no" ]]; then
 echo "Great So, make Changes to line 58 replace it with intenal-loadbalancer-dns "
elif [[ "$ans" == "yes" ]]; then
 echo "-------------------------------"
 echo "|      Installing Nodejs      |"
 echo "-------------------------------"

 curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
 source ~/.bashrc
 source ~/.nvm/nvm.sh
 nvm install 16
 nvm use 16


 echo "-------------------------------"
 echo "|    Creating Build Folder    |"
 echo "-------------------------------"

 cd application-code/web-tier
 npm install
 npm run build


 echo "-------------------------------"
 echo "|       Installing Nginx      |"
 echo "-------------------------------"

 sudo apt update
 sudo apt install nginx -y
 sudo systemctl stop nginx
 sudo rm -rf /var/www/html/*
 sudo cp -r build/* /var/www/html/


 echo "-------------------------------"
 echo "|    Changing nginx.conf      |"
 echo "-------------------------------"

 sudo rm /etc/nginx/nginx.conf
 sudo cp ../nginx.conf /etc/nginx/nginx.conf
 sudo systemctl restart nginx

 echo

 echo "---------------------------------------------------------------------------"
 echo "|           Now you can Create Image out of this Virtual machine          |"
 echo "---------------------------------------------------------------------------"

else
 echo 
 echo "Enter Valid Answer"
fi 

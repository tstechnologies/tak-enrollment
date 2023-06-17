#!/bin/bash
clear

# Distribution detection
if command -v lsb_release >/dev/null 2>&1; then
    DISTRIBUTION=$(lsb_release -si)
else
    DISTRIBUTION=$(cat /etc/os-release | grep -oP '(?<=^ID=).+' | tr -d '"')
fi

# Function to install packages based on distribution
install_packages() {
    if [[ $DISTRIBUTION == "Ubuntu" || $DISTRIBUTION == "Debian" ]]; then
        yes | sudo apt install "$@"
    elif [[ $DISTRIBUTION == "CentOS" || $DISTRIBUTION == "Rocky" ]]; then
        yes | sudo yum install "$@"
    else
        echo "Unsupported distribution: $DISTRIBUTION"
        exit 1
    fi
}

# Function to restart services based on distribution
restart_service() {
    if [[ $DISTRIBUTION == "Ubuntu" || $DISTRIBUTION == "Debian" ]]; then
        sudo systemctl restart "$@"
    elif [[ $DISTRIBUTION == "CentOS" || $DISTRIBUTION == "Rocky" ]]; then
        sudo service "$@" restart
    else
        echo "Unsupported distribution: $DISTRIBUTION"
        exit 1
    fi
}
sleep 2
clear

# --- #

echo "TAK Server Self Enrollment Setup"
echo " "
echo " "
sleep 5
echo "Installing nginx, python, and pip3"
sleep 2
echo " "

install_packages nginx python3 python3-pip

echo " "
echo " "

# --- #

sleep 2
echo "Installing flask and gunicorn"
sudo pip3 install flask
echo " "
sleep 3
sudo pip3 install gunicorn
echo " "
echo " "

# --- #

clear
sudo mkdir temp
sleep 1
echo " "
echo "You will be prompted for some info to modify the enrollment html page"
echo " "
echo "If you would like to modify the html later, please see the directory at"
echo "/opt/tak/enrollment/templates"
sleep 2
echo " "
echo -n "What is your organization's name? (This will be the server Title): "
read -r VAR_ORGANIZATION
echo "$VAR_ORGANIZATION" > temp/var_organization.txt
echo " "
sleep 2
echo -n "What is this server's FQDN (IE: tak.example.com): "
read -r DOMAIN
echo "$DOMAIN" > temp/domain.txt
sleep 5
clear

# --- #

echo " "
echo "Now modifying files for enrollment"
sleep 2
echo " "
sudo rm /etc/nginx/sites-enabled/default
sudo rm /etc/nginx/sites-available/default
sudo cp -r raw-files temp/
sed -i "s/DOMAIN/$(cat temp/domain.txt)/g" temp/raw-files/nginx-enrollment
sed -i "s/SERVERNAME/$(cat temp/var_organization.txt)/g" temp/raw-files/enrollment/templates/enrollment.html
sleep 1
sudo cp temp/raw-files/nginx-enrollment /etc/nginx/sites-enabled/
sudo cp -r temp/raw-files/enrollment /opt/tak/
sudo cp temp/raw-files/tak-enrollment.service /etc/systemd/system/
sleep 2
restart_service nginx
sleep 2
if [[ $DISTRIBUTION == "Ubuntu" || $DISTRIBUTION == "Debian" ]]; then
    sudo systemctl daemon-reload
elif [[ $DISTRIBUTION == "CentOS" || $DISTRIBUTION == "Rocky" ]]; then
    sudo service "$@" reload
else
    echo "Unsupported distribution: $DISTRIBUTION"
    exit 1
fi
sleep 2
sudo rm -r temp/
clear
echo "Complete!"
echo " "
echo " "
echo "Port 8447 is the HTTPS endpoint for the enrollment page"
echo "EX: https://tak.example.com:8447"
echo " "
echo "To change this port and/or SSL settings, see /etc/nginx/sites-enabled/nginx-enrollment under the listen field"
echo " "
echo "By default, this service is disabled and will print out an 'enrollment disabled' message"
sleep 2
echo " "
echo "To enable, execute 'sudo systemctl start tak-enrollment'"
echo " "
echo " "
sleep 1
echo "To disable, execute 'sudo systemctl stop tak-enrollment'"
echo " "
echo " "
exit

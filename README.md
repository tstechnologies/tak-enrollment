# TAK-Server Self Enrollment Add-on
User Self Enrollment for TAK Server (flat-file authentication/certificate-enrollment)

Script is designed to determine your OS type.

See: https://github.com/clptak/TAK-Server-Certificate-Enrollment-with-LetsEncrypt-Certs for public SSL setup. Script assumes you've followed a similar convention.
 
 #
 
<img src="https://github.com/tstechnologies/tak-enrollment/blob/main/enrollment-setup/raw-files/enrollment/static/tstak.png" width="500"/>

Vist us at [tstak.us](https://tstak.us) for your TAK server needs!

## Installation

    git clone https://github.com/tstechnologies/tak-enrollment.git
    
    cd tak-enrollment

    sudo bash enrollment-setup.sh

## Managment

By default service is set to stop and is disabled

Assumes port 8447 is fowarded to your server. You can change the port enrollment is available to by editing /etc/nginx/sites-enables/nginx-enrollment

    #To enable enrollment:
    
    sudo systemctl | service start tak-enrollment

    #To disabled enrollment:

    sudo systemctl | service stop tak-enrollment

## Screenshots

<img src="https://github.com/tstechnologies/tak-enrollment/blob/main/Enrollment-Enabled.png" width="500"/>

<img src="https://github.com/tstechnologies/tak-enrollment/blob/main/Enrollment-Disabled.png" width="500"/>


# Assembled by NetHunter for CCDN 2017
#!/bin/bash
clear
if [ $EUID -ne 0 ]; then
   echo "This script must be run as root" 1>&2
exit
fi
# Sets constants used for coloring output
# Syntax echo "${red}red text ${green}green text${reset}"
red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`
echo "${green}Running Lockdown Script..."
sleep 5
# Change password for root account
echo "Input New Password for Root Account:"
sleep 3
passwd
# Remove Aliases
echo "${red} Removing Aliases..."
unalias -a
# Fix file repositories

echo "Fixing Repositories..."
	mv /etc/apt/sources.list /etc/apt/sources.list.org
  VERSION=$(lsb_release -sc)
    echo "deb http://ftp.us.debian.org/debian/ $VERSION main"  > /etc/apt/sources.list
    echo "deb-src http://ftp.us.debian.org/debian/ $VERSION main" >> /etc/apt/sources.list

    echo "deb http://security.debian.org/debian-security $VERSION/updates main"  >> /etc/apt/sources.list
    echo "deb-src http://security.debian.org/debian-security $VERSION/updates main" >> /etc/apt/sources.list

# Install needed Software

echo "Installing Software..."
sleep 3
apt install glances ufw openssh-server -y
clear
# Check for multiple users with UID 0


# Reset crontab

echo -e "Resetting Crontab..."
sleep 3
crontab -r
cd /etc/
/bin/rm -f cron.deny # at.deny
echo root > cron.allow
#echo root >at.allow (Might not apply to newer Debian)
/bin/chown root:root cron.allow # at.allow
/bin/chmod 640 cron.allow # at.allow
clear
#----------------Remote Administration----------------#
echo "Cleaning up SSH..."
sleep 5
# Remove existing SSH keys

rm -rf ~/.ssh/*
rm -f ~/ssh/*.pub
rm -f ~/ssh/*key
clear
# Configure SSH server

echo "Configuring SSH Access..."
sleep 3
ufw allow ssh

clear
# Change SSH Config

sed -i "s/PermitRootLogin yes/PermitRootLogin no/g" /etc/ssh/sshd_config
sed -i "s/X11Forwarding yes/X11Forwarding no/g" /etc/ssh/sshd_config
#
echo -e "${reset}Would you like to \e[31mdisable ${reset}SSH password authentication?"
read ans
 if [ "$ans" = "Y" ] || [ "$ans" = "y" ];
 then
   sed -i "s/#PasswordAuthentication yes/PasswordAuthentication no/g" /etc/ssh/sshd_config
else
echo "Script is Done, Good Luck!${reset}"
fi
exit
fi

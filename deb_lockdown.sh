# Assembled by NetHunter for CCDN 2017
#!/bin/bash
/bin/clear
if [ $EUID -ne 0 ]; then
   /bin/echo "This script must be run as root" 1>&2
exit
fi
# Sets constants used for coloring output
# Syntax echo "${red}red text ${green}green text${reset}"
red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`
/bin/echo "${green}Running Lockdown Script..."
sleep 5

# Remove bashrc
/bin/echo "Archiving files"
sleep 3
/bin/mkdir ~/original
/bin/mv ~/.bash* ~/original
/bin/cp ~/competition/.bashrc ~
. ~/.bashrc

# Change password for root account
  echo "Input New Password for Root Account:"
/usr/bin/passwd

# Fix file repositories
  echo "Fixing Repositories..."
  sleep 3
	cp /etc/apt/sources.list ~/original/sources.list.org
  VERSION=$(lsb_release -sc)
  echo "deb http://ftp.us.debian.org/debian/ $VERSION main"  > /etc/apt/sources.list
  echo "deb-src http://ftp.us.debian.org/debian/ $VERSION main" >> /etc/apt/sources.list

  echo "deb http://security.debian.org/debian-security $VERSION/updates main"  >> /etc/apt/sources.list
  echo "deb-src http://security.debian.org/debian-security $VERSION/updates main" >> /etc/apt/sources.list

# Install needed Software

  echo "Installing Software..."
sleep 3
apt install glances ufw openssh-server -y
# Check for multiple users with UID 0


# Reset crontab
  echo -e "Resetting Crontab..."
sleep 3
cp /var/spool/cron ~/original
crontab -r
cd /etc/
mv cron.deny cron.allow ~/original # at.deny
  echo root > cron.allow
#echo root >at.allow (Might not apply to newer Debian)
/bin/chown root:root cron.allow # at.allow
/bin/chmod 640 cron.allow # at.allow
clear

#----------------Remote Administration----------------#
  echo "Cleaning up SSH..."
sleep 5

# Remove existing SSH keys
mv -n ~/.ssh/* ~/original
mv -n ~/ssh/*.pub ~/original
mv -n ~/ssh/*key ~/original
clear

# Configure SSH server
  echo "Configuring SSH Access..."
sleep 3
ufw allow ssh
clear

# Change SSH Config
cp /etc/ssh/sshd_config ~/original
sed -i "s/PermitRootLogin yes/PermitRootLogin no/g" /etc/ssh/sshd_config
sed -i "s/X11Forwarding yes/X11Forwarding no/g" /etc/ssh/sshd_config
  echo -e "${reset}Would you like to \e[31mdisable ${reset}SSH password authentication?"
read ans
 if [ "$ans" = "Y" ] || [ "$ans" = "y" ];
 then
   sed -i "s/#PasswordAuthentication yes/PasswordAuthentication no/g" /etc/ssh/sshd_config
else
  echo "Script is Done, Good Luck!${reset}"
 fi
 service sshd restart

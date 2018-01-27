# Assembled by NetHunter for CCDN 2017
#!/bin/bash
/usr/bin/clear
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
/bin/sleep 5

# Remove bashrc
/bin/echo "Archiving files"
/bin/sleep 3
/usr/bin/chattr -i ~/.bash*
/usr/bin/chattr -i ~/.profile*
/bin/mkdir ~/original
/bin/mv ~/.bash* ~/original
/bin/mv ~/.profile* ~/original

# Uncomment for paranoid mode
/usr/bin/apt-get --reinstall install -y passwd
/usr/bin/apt-get --reinstall install -y bash
/usr/bin/apt-get --reinstall install -y coreutils
/usr/bin/apt-get --reinstall install -y nano

# Change password for root account
  echo "Input New Password for Root Account:"
passwd

# Fix file repositories
  echo "Fixing Repositories..."
  sleep 3
  chattr -i /etc/apt/sources.list
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
# Remove protection and archive cronjobs
chattr -i /etc/crontab
chattr -i /var/spool/cron
mv /var/spool/cron ~/original
#mv /etc/cron* ~/original (Untested, may break cron)
#mv /etc/cron.d (Untested, may break cron)

# Allow only Root Cron
cd /etc/
chattr -i cron.*
mv cron.deny cron.allow ~/original # at.deny
  echo root > cron.allow
#echo root >at.allow (Might not apply to newer Debian)
/bin/chown root:root cron.allow # at.allow
/bin/chmod 600 cron.allow # at.allow
clear

# ----------------------Assign Permissions------------------ #
chown root:root /etc/passwd-
chmod 600 /etc/passwd-
chown root:root /etc/security/opasswd
chmod 600 /etc/security/opasswd
chown root:root /etc/shadow-
chmod 600 /etc/shadow-
chown root:root /etc/group-
chmod 600 /etc/group-
chown root:shadow /etc/shadow
chmod 640 /etc/shadow
chown root:root /etc/gshadow-
chmod 600 /etc/gshadow-

# Uncomment for Extreme Paranoia (Warning: May Break System)
chown -R root /etc

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
sed -i "s/.*PermitRootLogin.*/PermitRootLogin no/g" /etc/ssh/sshd_config
sed -i "s/.*X11Forwarding.*/X11Forwarding no/g" /etc/ssh/sshd_config
sed -i "s/.*MaxAuthTries.*/MaxAuthTries 1/g" /etc/ssh/sshd_config
  echo -e "${reset}Would you like to \e[31mdisable ${reset}SSH password authentication?"
read ans
 if [ "$ans" = "Y" ] || [ "$ans" = "y" ];
 then
   sed -i "s/.*PasswordAuthentication.*/PasswordAuthentication no/g" /etc/ssh/sshd_config
else
  echo "Script is Done, Good Luck!${reset}"
 fi
 service sshd restart

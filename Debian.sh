#!/bin/bash
## Baseline Script that is ran on a system to give you a baseline to go from there.
# Assembled by NetHunter with cjthedj97 for CCDN 2018

# Sets constants used for coloring output
# Syntax echo "${red}red text ${green}green text${reset}"
  red=`tput setaf 1`
  green=`tput setaf 2`
  reset=`tput sgr0`

  ## Checking to see if script was ran as root or with sudo privileges
  if [ $(id -u) != 0 ]; then
      echo "You're not root. Please run as root."
      exit
fi

  /usr/bin/clear
  #----------------------------------------------WHILE ONLINE------------------------------------------

  #-------------------------------Beginning of the Script-------------------------------
  # Test network DHCP configuration with ifup
    echo "${red}Starting the Script"
  sleep 5
    echo "Checking network connectivity"
  wget -q --tries=5 --timeout=20 --spider https://google.com
  if [[ $? -eq 0 ]]; then
    echo "Online"
  else
    echo "Offline"
  fi

## Checks the /etc/apt/sources.list and asks if it is correct
  echo "Please verify that the source list is correct"
  cat /etc/apt/sources.list | less
  echo "Is this correct?"
  echo "Enter Y or N"
  read a
  if [[ $a == "Y" || $a == "y" ]]; then
# If Correct then Runs the following
  echo "Starting the Script"
  sleep 5
  apt update -y &> ~/baseline/update.log
else

# Fix file repositories
  /bin/echo "Fixing Repositories...${reset}"
  /bin/sleep 3
  /bin/mkdir ~/original
  /usr/bin/chattr -i /etc/apt/sources.list
  /bin/cp /etc/apt/sources.list ~/original/sources.list.org
    VERSION=$(lsb_release -sc)
  /bin/echo "deb http://ftp.us.debian.org/debian/ $VERSION main"  > /etc/apt/sources.list
  /bin/echo "deb-src http://ftp.us.debian.org/debian/ $VERSION main" >> /etc/apt/sources.list
  /bin/echo "deb http://security.debian.org/debian-security $VERSION/updates main"  >> /etc/apt/sources.list
  /bin/echo "deb-src http://security.debian.org/debian-security $VERSION/updates main" >> /etc/apt/sources.list
  /usr/bin/apt-get update
clear
fi

# Uncomment for paranoid mode
  /bin/echo "${reset}Paranoia Mode: ${red}Active${reset}"
  /bin/echo "Reinstalling Essential Utilities"
  /usr/bin/apt-get --reinstall install -y passwd
  /usr/bin/apt-get --reinstall install -y bash
  /usr/bin/apt-get --reinstall install -y nano
  /usr/bin/apt-get --reinstall install -y coreutils
clear

# Installing the Required Software
  echo "Installing the required Software"
  sleep 5
	apt install curl nano lynx python tmux lynis glances ufw -y
clear

# Downloads and Runs IR (Incidence Response) program
  echo "Installing IR program"
  sleep 5
  git clone https://github.com/SekoiaLab/Fastir_Collector_Linux
  cd Fastir_Collector_Linux
  python fastIR_collector_linux.py &> ~/baseline/fastir.log
  cp -R output/ ~/baseline/output
clear

# Updating the system
  echo "Upgrading system"
  apt upgrade -y
clear

  ip addr
  echo "${green}Utilities repaired, select interface to bring down to continue:"
  read interface
  ip link set $interface down
clear
#----------------------------------------------WHILE OFFLINE------------------------------------------
# Setting up and Installing Lynis
  echo "Starting Lynis"
  Sleep 5
  lynis audit system
  cp /var/log/lynis.log ~/baseline/output/lynis.log
  cp /var/log/lynis-report.dat ~/baseline/output/lynis-report.dat

# Remove bashrc
  echo "${red}Archiving files"
  sleep 3
  chattr -i ~/.bash*
  chattr -i ~/.profile*
  mv ~/.bash* ~/original
  mv ~/.profile* ~/original

# Change password for root account
  echo "${green}Input New Password for Root Account:"
  passwd

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
  cd ~/etc/
  chattr -i cron.*
  mv cron.deny cron.allow ~/original # at.deny
  echo root > cron.allow
#echo root >at.allow (Might not apply to newer Debian)
  chown root:root cron.allow # at.allow
  chmod 600 cron.allow # at.allow
clear

# ----------------------Assign Permissions------------------
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
#  chown -R root /etc
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
  sed -i "s/.*PermitRootLogin.*/PermitRootLogin no/g" /etc/ssh/sshd_config
  sed -i "s/.*X11Forwarding.*/X11Forwarding no/g" /etc/ssh/sshd_config
  sed -i "s/.*MaxAuthTries.*/MaxAuthTries 1/g" /etc/ssh/sshd_config
    echo -e "${reset}Would you like to \e[31mdisable ${reset}SSH password authentication?"
  read ans
   if [ "$ans" = "Y" ] || [ "$ans" = "y" ];
   then
     sed -i "s/.*PasswordAuthentication.*/PasswordAuthentication no/g" /etc/ssh/sshd_config
  else
    echo "Remember to DISABLE Password Authentication ASAP${reset}"
  sleep 3
fi
   service sshd restart

# Check to see if system reboot is required
  if [ -f /var/run/reboot-required ]; then
  echo 'Reboot Required, please consider rebooting'
  sleep 5
fi

# Re-enable networking
  ip link set $interface up
  echo "Script is Done, Good Luck!${reset}"
  sleep 3
clear
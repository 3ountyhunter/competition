# Assembled by NetHunter for CCDN 2017
#!/bin/bash

if [ $EUID -ne 0 ]; then
   echo "This script must be run as root" 1>&2
exit
fi
# Remove Aliases
unalias -a
# Install needed Software
apt install glances ufw openssh-server -y
# Change password for root account

echo "Input New Password for Root Account:"
passwd

# Check for multiple users with UID 0


# Reset crontab
crontab -r
cd /etc/
/bin/rm -f cron.deny at.deny
echo root > cron.allow
#echo root >at.allow (Might not apply to newer Debian)
/bin/chown root:root cron.allow at.allow
/bin/chmod 640 cron.allow at.allow

#----------------Remote Administration----------------#
# Remove existing SSH keys
rm -rf ~/.ssh/*
rm -f ~/ssh/*.pub
rm -f ~/ssh/*key
ssh-keygen -R
# Configure SSH server
echo "Configuring SSH Access"
ufw allow ssh

# Change SSH Config

sed -i "s/PermitRootLogin yes/PermitRootLogin no/g" /etc/ssh/sshd_config
sed -i "s/X11Forwarding yes/X11Forwarding no/g" /etc/ssh/sshd_config

echo "Would you like to disable SSH password authentication?"
read ans
 if [ "$ans" = "Y" ] || [ "$ans" = "y" ]
 then
# sed -i "s/#PasswordAuthentication yes/PasswordAuthentication no/g" /etc/ssh/sshd_config
fi
echo Fallout

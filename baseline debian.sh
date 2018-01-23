#!/bin/bash
## Baseline Script that is ran on a system to give you a baseline to go from there.
## Written by cjthedj97 on Github

## The Start of the Script

## Checking to see if script was ran as root or with sudo privileges
if [ $(id -u) != 0 ]; then
    echo "You're not root. Please run as root."
    exit
fi

## Checks the /etc/apt/sources.list and ask if it is correct
echo "Please verify that the source list is correct"
cat /etc/apt/sources.list | less
echo "Is this correct?"
echo "Enter Y or N"
read a
if [[ $a == "Y" || $a == "Y" ]]; then
  # If Correct then Runs the following
  echo "Starting the Script"
  sleep 5
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C80E383C3DE9F082E01391A0366C67DE91CA5D5F
  apt install apt-transport-https
  codename=$(lsb_release -c)
  touch /etc/apt/preferences.d/lynis
  echo "Package: lynis" >> /etc/apt/preferences.d/lynis
  echo "Pin: origin packages.cisofy.com" >> /etc/apt/preferences.d/lynis
  echo "Pin-Priority: 600" >> /etc/apt/preferences.d/lynis

  # Add the correct repo based on the verson of debian running
  if [[ $codename = "stretch" ]]
  then
    echo "deb https://packages.cisofy.com/community/lynis/deb/ stretch main" > /etc/apt/sources.list.d/cisofy-lynis.list
  fi

  if [[ $codename = "jessie" ]]
  then
    echo "deb https://packages.cisofy.com/community/lynis/deb/ jessie main" > /etc/apt/sources.list.d/cisofy-lynis.list
  fi

  if [[ $codename = "wheezy" ]]
  then
    echo "deb https://packages.cisofy.com/community/lynis/deb/ wheezy main" > /etc/apt/sources.list.d/cisofy-lynis.list
  fi
 apt update -y &> ~/baseline/update.log

  # Installing the Required Software
  echo "Installing the required Software"
  sleep 5
        apt install curl git nano lynx python tmux lynis -y

  # Downloads and Runs IR (Incidance Response) program
  echo "Installing IR program"
  sleep 5
  git clone https://github.com/SekoiaLab/Fastir_Collector_Linux
  cd Fastir_Collector_Linux
  python fastIR_collector_linux.py &> ~/baseline/fastir.log
  cp -R output/ ~/baseline/output

  # Setting up and Installing Lynis
  echo "Starting Lynis"
  Sleep 5
  lynis audit system
  cp /var/log/lynis.log ~/baseline/output/lynis.log
  cp /var/log/lynis-report.dat ~/baseline/output/lynis-report.dat

  # Updating the system
  echo "Upgrading"
  apt upgrade -y

  # Parse lynis-report.dat for easier viewing      #NetHunter
     echo "Review parsed output for system compliance"
  sleep 5
  touch ~/baseline/output/parsed.log
     echo "System Information ******************************************************************************************************************************************" >> ~/baseline/output/parsed.log
  cat ~/baseline/output/lynis-report.dat | grep os_version >> ~/baseline/output/parsed.log
  cat ~/baseline/output/lynis-report.dat | grep nameserver >> ~/baseline/output/parsed.log
  cat ~/baseline/output/lynis-report.dat | grep network_ | sed -e 's/network_\[\]=//g' >> ~/baseline/output/parsed.log
  cat ~/baseline/output/lynis-report.dat | grep firewall_ >> ~/baseline/output/parsed.log
  cat ~/baseline/output/lynis-report.dat | grep cronjob >> ~/baseline/output/parsed.log
  cat ~/baseline/output/lynis-report.dat | grep real_user | sed -e 's/real_user\[\]=//g' >> ~/baseline/output/parsed.log
  cat ~/baseline/output/lynis-report.dat | grep available_shell | sed -e 's/available_shell\[\]=//g' >> ~/baseline/output/parsed.log
     echo "Warnings ******************************************************************************************************************************************" >> ~/baseline/output/parsed.log
   cat ~/baseline/output/lynis-report.dat | grep warning | sed -e 's/warning\[\]=//g' >> ~/baseline/output/parsed.log
     echo "Suggestion ****************************************************************************************************************************************" >> ~/baseline/output/parsed.log
   cat ~/baseline/output/lynis-report.dat | grep suggestion | sed -e 's/suggestion\[\]=//g' >> ~/baseline/output/parsed.log
  # Displays parsed log
   cat ~/baseline/output/parsed.log | less

        # Check to see if system reboot is required
  if [ -f /var/run/reboot-required ]; then
  echo 'Reboot Required, please consiter rebooting'
  sleep 5
  exit
  fi
else
        echo "You entered N or an incorrct response"
        echo "Please try again later"
fi

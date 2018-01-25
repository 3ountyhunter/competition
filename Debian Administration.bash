#!/bin/bash
clear

# ***********************************************************************************************
# Script Name: Cmds
# Programmer: Timothy Warren
# Additions by Nethunter
# Title: Adjunt Faculty Baker College
#
#
# Email: twarre03@baker.edu
# Phone:
#
#
# Date Written: 04/05/2017
# Date Deployed: 04/05/2017
# Date Revised: 1/23/2018
# Current Revision Level: 2.0
#
#
# Functional Synopsis: Bash Case Script used to provide ease of access to
#                      often used commands and utilities.
#
# Revision History: Configured script for 2018 CCDN
#
#
#
#
# ***********************************************************************************************

while true ; do
 echo -n "
 1. Run ifconfig
 2. Run ping x10 After You Enter A Destination IP Address
 3. Run dig After You Enter A Destination IP Address
 4. Run init 0 Emergency Shutdown
 5. Run init 6 Restart Server
 0. Exit to Shell

 Enter Choice: "
 read numchoice
clear
case $numchoice in
        "1" ) ifconfig ;;
        "2" ) echo "Enter Site IP Address?"
			  read site
			  ping -c 10 $site ;;
        "3" ) echo "Enter Site IP Address?"
			  read site
			  dig $site ;;
        "4" ) init 0 ;;
	    "5" ) init 6 ;;
        "0" ) break ;;
        * ) echo -n "You Have Entered An Incorrect Option. Please Enter the Correct Option." ;;
 esac
done

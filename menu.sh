#!/bin/bash
# Sanity Check
#    #######################################################
echo "$(tput setaf 4)-------------------------------------------------------"
echo "$(tput setaf 0)$(tput setab 7)Since we need to run the menu with elevated privileges$(tput sgr 0)"
echo "$(tput setaf 0)$(tput setab 7)Please enter your password now.$(tput sgr 0)"
echo "$(tput setaf 4)-------------------------------------------------------"
#    ###################################################### 
[[ "$EUID" -eq 0 ]] || exec sudo "$0" "$@"

# MAIN BRANCH MENU
#  THIS IS STILL A WORK IN PROGRESS BUT ALL THE FUNCTIONS WORK
#  I NEED TO JUST CLEAN IT UP AND FORMAT BETTER
#  PLEASE LET ME KNOW ABOUT ISSUES
#  UPDATE THE MENU BEFORE YOU USE IT 
# If Frankenstein was a bash script
# Please help improve this script
# Easy Valheim Server Menu super duper easy
# Open to other commands that should be used... 
clear
###############################################################
#Only change this if you know what you are doing
#Valheim Server Install location(Default) 
valheimInstallPath=/home/steam/valheimserver
#Valheim World Data Path(Default)
worldpath=/home/steam/.config/unity3d/IronGate/Valheim/worlds
#Backup Directory ( Default )
backupPath=/home/steam/backups
###############################################################

# Set Menu Version
mversion="Version 1.8-Loki"
##
# Update Menu script 
##


##
# Admin Tools:
# -Backup World: Manual backups of .db and .fwl files
# -Restore World: Manual restore of .db and .fwl files
# -Stop Valheim Server: Stops the Valheim Service
# -Start Valheim Server: Starts the Valheim Service
# -Restart Valheim Server: Restarts the Valheim Service (stop/start)
# -Status Valheim Server: Displays the current status of the Valheim Server Service
# -Check and Apply Valheim Server Update: Reaches out to to Steam with steamcmd and looks for official updates. If found applies them and restarts Valheim services
# -Edit Valheim Configuration File from menu
# -Fresh Valheim Server: Installs Valheim server from official Steam repo. 
##

##
# Tech Support Tools
#Display Valheim Config File
#Display Valheim Server Service
#Display World Data Folder
#Display System Info
#Display Network Info
#Display Connected Players History
##

##
# Adding Valheim Mod Support
##

MENUSCRIPT="$(readlink -f "$0")"
SCRIPTFILE="$(basename "$MENUSCRIPT")"            
SCRIPTPATH="$(dirname "$SCRIPT")"
SCRIPTNAME="$0"
ARGS=( "$@" )

# Add color support
source "${SCRIPTPATH}/lib/colors.sh"

########################################################################
#####################Check for Menu Updates#############################
########################################################################
 
BRANCH=$(git rev-parse --abbrev-ref HEAD)
UPSTREAM=$(git rev-parse --abbrev-ref --symbolic-full-name @{upstream})

function script_check_update() {
    #Look I know this is not pretty like Loki's face but it works!
    git fetch
    [ -n "$(git diff --name-only "$UPSTREAM" "$SCRIPTFILE")" ] && {
      echo "BY THORS HAMMER take a peek inside Valhalla!!"
      sleep 1
      git pull --force
      git stash
      git checkout "$BRANCH"
      git pull --force
      echo " Updating"
      sleep 1
      cd /opt/Dedicated_Valheim_server_Script/
      chmod +x menu.sh
      exec "$SCRIPTNAME" "${ARGS[@]}"

      # Now exit this old instance
      exit 1
    }
    echo "Oh for Loki sakes! No updates to be had... back to choring! "
}

########################################################################
###################Install Valheim Server###############################
########################################################################
function valheim_server_install() {
  lib/install.sh --interactive yes --path "${valheimInstallPath}"
}

########################################################################
###################Backup World DB and FWL Files########################
########################################################################
function backup_world_data() {
  lib/backup.sh --interactive --backup_path "${backupPath}" --world_path "${worldpath}"
}

########################################################################
##################Restore World Files DB and FWL########################
########################################################################

# Thanks to GITHUB @LachlanMac and @Kurt
function restore_world_data() {
  lib/restore.sh --interactive --backup_path "${backupPath}" --world_path "${worldpath}" --install_path "${valheimInstallPath}"
}

########################################################################
######################beta updater for Valheim##########################
########################################################################
########################################################################
######################beta updater for Valheim##########################
########################################################################
#function check_apply_server_updates_beta() {
#    echo ""
#    echo "Downloading Official Valheim Repo Log Data for comparison only"
#      repoValheim=$(/home/steam/steamcmd +login anonymous +app_info_update 1 +app_info_print 896660 +quit | grep -A10 branches | grep -A2 public | grep buildid | cut -d'"' -f4)
#      echo "Official Valheim-: $repoValheim"
#      localValheim=$(grep buildid ${valheimInstallPath}/steamapps/appmanifest_896660.acf | cut -d'"' -f4)
#      echo "Local Valheim Ver: $localValheim"
#      if [ "$repoValheim" == "$localValheim" ]; then
#        echo "No new Updates found"
#	sleep 2
#	else
#	echo "Update Found kicking process to Odin for updating!"
#	sleep 2
#        continue_with_valheim_update_install
#        echo ""
#     fi
#     echo ""
#}
function check_apply_server_updates_beta() {
  lib/update.sh --interactive --install_path "${valheimInstallPath}"
}

########################################################################
##############Verify Checking Updates for Valheim Server################
########################################################################

function confirm_check_apply_server_updates() {

while true; do
echo -ne "
$(ColorRed '------------------------------------------------------------')"
echo ""
tput setaf 2; echo "The Script will download the Log Data from the official" ; tput setaf 9;
tput setaf 2; echo "Steam Valheim Repo and compare the data." ; tput setaf 9;
tput setaf 2; echo "No changes will be made, until you agree later." ; tput setaf 9;
tput setaf 2; echo "Press y(YES) and n(NO)" ; tput setaf 9;
echo -ne "
$(ColorRed '------------------------------------------------------------')"
echo ""
tput setaf 2; read -p "Do you wish to continue?" yn ; tput setaf 9; 
echo -ne "
$(ColorRed '------------------------------------------------------------')"
    case $yn in
        [Yy]* ) check_apply_server_updates_beta; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

}

########################################################################
###############Display Valheim Start Configuration######################
########################################################################

function display_start_valheim() {
    clear
    echo ""
    sudo cat ${valheimInstallPath}/start_valheim.sh
    echo ""

}

########################################################################
###############Display Valheim World Data Folder########################
########################################################################

function display_world_data_folder() {
    clear
    echo ""
    sudo ls -lisa $worldpath
    echo ""

}

########################################################################
######################Stop Valheim Server Service#######################
########################################################################


function stop_valheim_server() {
    clear
    echo ""
    echo -ne "
$(ColorOrange '--------------------Stop Valheim Server---------------------')
$(ColorRed '------------------------------------------------------------')"
echo ""
tput setaf 2; echo "You are about to STOP the Valheim Server" ; tput setaf 9; 
tput setaf 2; echo "You are you sure y(YES) or n(NO)?" ; tput setaf 9; 
echo -ne "
$(ColorRed '------------------------------------------------------------')"
echo ""
 read -p "Please confirm:" confirmStop
#if y, then continue, else cancel
        if [ "$confirmStop" == "y" ]; then
    echo ""
    echo "Stopping Valheim Server Services"
    sudo systemctl stop valheimserver.service
    echo ""
    else
    echo "Canceling Stopping of Valheim Server Service - because Loki sucks"
    sleep 3
    clear
fi
}

########################################################################
###################Start Valheim Server Service#########################
########################################################################


function start_valheim_server() {
    clear
    echo ""
    echo -ne "
    $(ColorOrange '-------------------Start Valheim Server---------------------')
    $(ColorRed '------------------------------------------------------------')"
    echo ""
    tput setaf 2; echo "You are about to START the Valheim Server" ; tput setaf 9;
    tput setaf 2; echo "You are you sure y(YES) or n(NO)?" ; tput setaf 9;
    echo -ne "
    $(ColorRed '------------------------------------------------------------')"
    echo ""
    read -p "Please confirm:" confirmStart
    #if y, then continue, else cancel
        if [ "$confirmStart" == "y" ]; then
    echo ""
    tput setaf 2; echo "Starting Valheim Server with Thor's Hammer!!!!" ; tput setaf 9;
    sudo systemctl start valheimserver.service
    echo ""
    else
        echo "Canceling Starting of Valheim Server Service - because Loki sucks"
        sleep 3
    clear
fi
}

########################################################################
####################Restart Valheim Server Service######################
########################################################################

function restart_valheim_server() {
    clear
    echo ""
    echo -ne "
$(ColorOrange '------------------Restart Valheim Server--------------------')
$(ColorRed '------------------------------------------------------------')"
echo ""
tput setaf 2; echo "You are about to RESTART the Valheim Server" ; tput setaf 9; 
tput setaf 2; echo "You are you sure y(YES) or n(NO)?" ; tput setaf 9; 
echo -ne "
$(ColorRed '------------------------------------------------------------')"
echo ""
 read -p "Please confirm:" confirmRestart
#if y, then continue, else cancel
        if [ "$confirmRestart" == "y" ]; then
tput setaf 2; echo "Restarting Valheim Server with Thor's Hammer!!!!" ; tput setaf 9; 
    sudo systemctl restart valheimserver.service
    echo ""
    else
        echo "Canceling Restarting of Valheim Server Service - because Loki sucks"
        sleep 3
    clear
fi
}

########################################################################
#####################Display Valheim Server Status######################
########################################################################

function display_valheim_server_status() {
    clear
    echo ""
    sudo systemctl status --no-pager -l valheimserver.service
    echo ""

}

########################################################################
##############Display Valheim Vanilla Configuration File################
########################################################################


function display_start_valheim() {
    clear
    echo ""
    sudo cat ${valheimInstallPath}/start_valheim.sh
    echo ""

}

########################################################################
#######################Sub Server Menu System###########################
########################################################################

server_install_menu() {
  echo ""
  echo -ne "

  $(ColorOrange '----------------Server System Information-------------------')
  $(ColorOrange '-')$(ColorGreen '1)') Fresh or Reinstall Valheim Server
  $(ColorOrange '-')$(ColorGreen '0)') Go to Main Menu
  $(ColorOrange '------------------------------------------------------------')
  $(ColorPurple 'Choose an option:') "
  read a
  case $a in
    1) valheim_server_install ; server_install_menu ;;
    0) menu ; menu ;;
    *)  echo -ne " $(ColorRed 'Wrong option.')" ; server_install_menu ;;
  esac
}
########################################################################
#########################Print System INFOS#############################
########################################################################


function display_system_info() {
clear
echo ""
    echo -e "-------------------------------System Information----------------------------"
    echo -e "Hostname:\t\t"`hostname`
    echo -e "uptime:\t\t\t"`uptime | awk '{print $3,$4}' | sed 's/,//'`
    echo -e "Manufacturer:\t\t"`cat /sys/class/dmi/id/chassis_vendor`
    echo -e "Product Name:\t\t"`cat /sys/class/dmi/id/product_name`
    echo -e "Version:\t\t"`cat /sys/class/dmi/id/product_version`
    echo -e "Serial Number:\t\t"`cat /sys/class/dmi/id/product_serial`
    echo -e "Machine Type:\t\t"`vserver=$(lscpu | grep Hypervisor | wc -l); if [ $vserver -gt 0 ]; then echo "VM"; else echo "Physical"; fi`
    echo -e "Operating System:\t"`hostnamectl | grep "Operating System" | cut -d ' ' -f5-`
    echo -e "Kernel:\t\t\t"`uname -r`
    echo -e "Architecture:\t\t"`arch`
    echo -e "Processor Name:\t\t"`awk -F':' '/^model name/ {print $2}' /proc/cpuinfo | uniq | sed -e 's/^[ \t]*//'`
    echo -e "Active User:\t\t"`w | cut -d ' ' -f1 | grep -v USER | xargs -n1`
    echo -e "System Main IP:\t\t"`hostname -I`
echo ""
    echo -e "-------------------------------CPU/Memory Usage------------------------------"
    echo -e "Memory Usage:\t"`free | awk '/Mem/{printf("%.2f%"), $3/$2*100}'`
    echo -e "CPU Usage:\t"`cat /proc/stat | awk '/cpu/{printf("%.2f%\n"), ($2+$4)*100/($2+$4+$5)}' |  awk '{print $0}' | head -1`
echo ""
    echo -e "-------------------------------Disk Usage >80%-------------------------------"
    df -Ph | sed s/%//g | awk '{ if($5 > 80) print $0;}'
echo ""
}

########################################################################
#############################PRINT NETWORK INFO#########################
########################################################################

function display_network_info() {
clear
    echo ""
    sudo netstat -atunp | grep valheim
    echo ""

}

########################################################################
################Display History of Connected Players####################
########################################################################

function display_player_history() {
clear
    echo ""
    sudo cat /var/log/syslog | grep ZDOID
    echo ""

}

########################################################################
#####################Sub Tech Support Menu System#######################
########################################################################

tech_support(){
  echo ""
  echo -ne "
  $(ColorOrange '--------------------Valheim Tech Support--------------------')
  $(ColorOrange '-')$(ColorGreen ' 1)') Display Valheim Config File
  $(ColorOrange '-')$(ColorGreen ' 2)') Display Valheim Server Service
  $(ColorOrange '-')$(ColorGreen ' 3)') Display World Data Folder
  $(ColorOrange '-')$(ColorGreen ' 4)') Display System Info
  $(ColorOrange '-')$(ColorGreen ' 5)') Display Network Info
  $(ColorOrange '-')$(ColorGreen ' 6)') Display Connected Players History
  $(ColorOrange '------------------------------------------------------------')
  $(ColorOrange '-')$(ColorGreen ' 0)') Go to Main Menu
  $(ColorOrange '------------------------------------------------------------')
  $(ColorPurple 'Choose an option:') "
  read a
  case $a in
    1) display_start_valheim ; tech_support ;; 
		2) display_valheim_server_status ; tech_support ;;
    3) display_world_data_folder ; tech_support ;;
		4) display_system_info ; tech_support ;;
		5) display_network_info ; tech_support ;;
    6) display_player_history ; tech_support ;;
    0) menu ; menu ;;
    *)  echo -ne " $(ColorRed 'Wrong option.')" ; tech_support ;;
  esac
}

########################################################################
########################Sub Admin Menu System###########################
########################################################################

admin_tools_menu(){
  echo ""
  echo -ne "
  $(ColorOrange '---------------Valheim Backup and Restore Tools-------------')
  $(ColorOrange '-')$(ColorGreen ' 1)') Backup World (stop/starts Valheim)
  $(ColorOrange '-')$(ColorGreen ' 2)') Restore World
  $(ColorOrange '--------------------Valheim Service Tools-------------------')
  $(ColorOrange '-')$(ColorGreen ' 3)') Stop Valheim Server
  $(ColorOrange '-')$(ColorGreen ' 4)') Start Valheim Server
  $(ColorOrange '-')$(ColorGreen ' 5)') Restart Valheim Server
  $(ColorOrange '-')$(ColorGreen ' 6)') Status Valheim Server
  $(ColorOrange '----------------Official Valheim Server Update--------------')
  $(ColorOrange '-')$(ColorGreen ' 7)') Check and Apply Valheim Server Update
  $(ColorOrange '------------------First Time or Reinstall-------------------')
  $(ColorOrange '-')$(ColorGreen ' 8)') Fresh Valheim Server
  $(ColorOrange '-------------Edit start_valehim.sh Configuration------------')
  $(ColorOrange '-')$(ColorGreen ' 9)') Edit Valheim Startup Config File
  $(ColorOrange '------------------------------------------------------------')
  $(ColorOrange '-')$(ColorGreen ' 0)') Go to Main Menu
  $(ColorPurple 'Choose an option:') "
  read a
  case $a in
		1) backup_world_data ; admin_tools_menu ;;
		2) restore_world_data ; admin_tools_menu ;;
		3) stop_valheim_server ; admin_tools_menu ;;
		4) start_valheim_server ; admin_tools_menu ;;
		5) restart_valheim_server ; admin_tools_menu ;;
		6) display_valheim_server_status ; admin_tools_menu ;;
		7) confirm_check_apply_server_updates ; admin_tools_menu ;;
		8) lib ; admin_tools_menu ;;
		9) admin_valheim_config_edit ; admin_tools_menu ;;		
    0) menu ; menu ;;
    *)  echo -ne " $(ColorRed 'Wrong option.')" ; admin_tools_menu ;;
  esac
}

########################################################################
#######################START VALHEIM MOD SECTION########################
########################################################################



function install_mod_valheim() {
clear
    echo ""
    echo "Install Valheim Mods"
    echo "Coming Soon"
    echo ""

}

function remove_mod_valheim() {
clear
    echo ""
    echo "Remove Valheim Mods"
    echo "Coming Soon"
    echo ""

}

function update_valheim_mods() {
clear
    echo ""
    echo "Update Valheim Mods"
    echo "Coming Soon"
    echo ""

}

function valheim_mod_options() {
clear
    echo ""
    echo "Valheim Mod Options"
    echo "Coming Soon"
    echo ""

}

########################################################################
######################START MOD SECTION AREAS###########################
########################################################################

function server_mods() {
    clear
    echo ""
    echo "Server Related Mods"
    echo "Coming Soon"
    echo ""

}

function player_mods() {
    clear
    echo ""
    echo "Player Related Mods"
    echo "Coming Soon"
    echo ""

}

function building_mods() {
    clear
    echo ""
    echo "Building Related Mods"
    echo "Coming Soon"
    echo ""

}

function other_mods() {
    clear
    echo ""
    echo "Other Related Mods"
    echo "Coming Soon"
    echo ""

}

########################################################################
######################END MOD SECTION AREAS###########################
########################################################################


valheim_mods_options(){
echo ""
echo -ne "
$(ColorRed '-------NOT ADDED YET BUILDING FRAME WORK---------')
$(ColorCyan '---------------------Valheim Mod Menu----------------------')
$(ColorCyan '-')$(ColorGreen ' 1)') Server Mods
$(ColorCyan '-')$(ColorGreen ' 2)') Player Mods
$(ColorCyan '-')$(ColorGreen ' 3)') Building Mods
$(ColorCyan '-')$(ColorGreen ' 4)') Other Mods
$(ColorCyan '------------------------------------------------------------')
$(ColorCyan '-')$(ColorGreen ' 0)') Go to Valheim Mod Main Menu
$(ColorCyan '-')$(ColorGreen ' 00)') Go to Main Menu
$(ColorPurple 'Choose an option:') "
        read a
        case $a in
		1) server_mods ; valheim_mods_options ;;
		2) player_mods ; valheim_mods_options ;;
		3) building_mods ; valheim_mods_options ;;
		4) other_mods ; valheim_mods_options ;;
		   0) mods_menu ; menu ;;
		   00) menu ; menu ;;
		    *)  echo -ne " $(ColorRed 'Wrong option.')" ; valheim_mods_options ;;
        esac
}


mods_menu(){
echo ""
echo -ne "
$(ColorCyan '---------------Valheim Mod Install Remove Update---------------')
$(ColorCyan '-')$(ColorGreen ' 1)') Install Valheim Mods 
$(ColorCyan '-')$(ColorGreen ' 2)') Remove Valheim Mods 
$(ColorCyan '-')$(ColorGreen ' 3)') Update Valheim Mods 
$(ColorCyan '---------------------Valheim Mod Menu----------------------')
$(ColorCyan '-')$(ColorGreen ' 4)') Valheim Mods Options
$(ColorCyan '------------------------------------------------------------')
$(ColorCyan '-')$(ColorGreen ' 0)') Go to Main Menu
$(ColorPurple 'Choose an option:') "
        read a
        case $a in
		1) install_mod_valheim ; mods_menu ;;
		2) remove_mod_valheim ; mods_menu ;;
		3) update_valheim_mods ; mods_menu ;;
		4) valheim_mods_options ; mods_menu ;;
		   0) menu ; menu ;;
		    *)  echo -ne " $(ColorRed 'Wrong option.')" ; mods_menu ;;
        esac
}
########################################################################
#######################FINISH VALHEIM MOD SECTION#######################
########################################################################


########################################################################
##################START CHANGE VALHEIM START CONFIG#####################
########################################################################

function get_current_config() {
    currentDisplayName=$(perl -n -e '/\-name "?([^"]+)"? \-port/ && print "$1\n"' ${valheimInstallPath}/start_valheim.sh)
    currentPort=$(perl -n -e '/\-port "?([^"]+)"? \-nographics/ && print "$1\n"' ${valheimInstallPath}/start_valheim.sh)
    currentWorldName=$(perl -n -e '/\-world "?([^"]+)"? \-password/ && print "$1\n"' ${valheimInstallPath}/start_valheim.sh)
    currentPassword=$(perl -n -e '/\-password "?([^"]+)"?$/ && print "$1\n"' ${valheimInstallPath}/start_valheim.sh)
}

function print_current_config() {
    clear
    echo "Current Public Server Name: ${currentDisplayName}"
    echo "Current Port Information(default:2456): ${currentPort}"
    echo "Current Local World Name: ${currentWorldName} # Do not change unless you know what you are doing"
    echo "Current Server Access Password: ${currentPassword}"
}

function set_config_defaults() {
    #assign current varibles to set variables
    #if no are changes are made set variables will write to new config file anyways. No harm done
    #if changes are made set variables are updated with new data and will be wrote to new config file

    setCurrentDisplayName=$currentDisplayName
    setCurrentPort=$currentPort
    setCurrentWorldName=$currentWorldName
    setCurrentPassword=$currentPassword
}

function write_config_and_restart() {
    tput setaf 1; echo "Rebuilding Valheim start_valheim.sh configuration file" ; tput setaf 9;
    sleep 1
    cat > ${valheimInstallPath}/start_valheim.sh <<EOF
#!/bin/bash
export templdpath=\$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=./linux64:\$LD_LIBRARY_PATH
export SteamAppId=892970
# Tip: Make a local copy of this script to avoid it being overwritten by steam.
# NOTE: You need to make sure the ports 2456-2458 is being forwarded to your server through your local router & firewall.
./valheim_server.x86_64 -name "${setCurrentDisplayName}" -port ${setCurrentPort} -nographics -batchmode -world "${setCurrentWorldName}" -password "${setCurrentPassword}"
export LD_LIBRARY_PATH=\$templdpath
EOF
   echo "Setting Ownership to steam user and execute permissions on " ${valheimInstallPath}/start_valheim.sh
   chown steam:steam ${valheimInstallPath}/start_valheim.sh
   chmod +x ${valheimInstallPath}/start_valheim.sh
   echo "done"
   echo "Restarting Valheim Server Service"
   sudo systemctl restart valheimserver.service
   echo ""
}

function change_public_display_name() {
    get_current_config
    print_current_config
    set_config_defaults
    echo ""
    tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
    tput setaf 2; echo "------------------Set New Public Display Name---------------" ; tput setaf 9;
    tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
    tput setaf 1; echo "Now for Loki, please follow instructions" ; tput setaf 9;
    tput setaf 1; echo "The Server is required to have a public display name" ; tput setaf 9;
    tput setaf 1; echo "Do not use SPECIAL characters:" ; tput setaf 9;
    tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
    tput setaf 2; echo "Current Public Display Name: ${currentDisplayName}" ; tput setaf 9;
    tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
    echo ""
    read -p "Enter new public server display name: " setCurrentDisplayName
    echo ""
    tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
    echo ""
    tput setaf 5; echo "Old Public Display Name: " ${currentDisplayName} ; tput setaf 9;
    tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
    echo ""
    tput setaf 1; echo "New Public Display Name:" ${setCurrentDisplayName} ; tput setaf 9;
    echo ""
    tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
    echo ""
    read -p "Do you wish to continue with these changes? (y=Yes, n=No):" confirmPublicNameChange
    #if y, then continue, else cancel
    if [ "$confirmPublicNameChange" == "y" ]; then
        write_config_and_restart
    else
        echo "Canceled the renaming of Public Valheim Server Display Name - because Loki sucks"
        sleep 3
        clear
    fi
}
    
function change_default_server_port() {
    get_current_config
    print_current_config
    set_config_defaults
    echo ""
    tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
    tput setaf 2; echo "---------------------Set New Server Port--------------------" ; tput setaf 9;
    tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
    tput setaf 1; echo "Now for Loki, please follow instructions" ; tput setaf 9;
    tput setaf 1; echo "The Server is required to have a port to operate on" ; tput setaf 9;
    tput setaf 1; echo "Do not use SPECIAL characters:" ; tput setaf 9;
    tput setaf 1; echo "New assigned port must be greater than 3000:" ; tput setaf 9;
    tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
    tput setaf 2; echo "Current Server Port: ${currentPort} " ; tput setaf 9;
    tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
    echo ""
    while true; do
        read -p "Enter new Server Port (Default:2456): " setCurrentPort
        echo ""
         #check to make sure nobody types stupid Loki Jokes in here
        [[ ${#setCurrentPort} -ge 4 && ${#setCurrentPort} -le 6 ]] && [[ $setCurrentPort -gt 1024 && $setCurrentPort -le 65530 ]] && [[ "$setCurrentPort" =~ ^[[:alnum:]]+$ ]] && break
        echo ""
        echo "Try again, Loki got you or you typed something wrong or your port range is incorrect"
    done
    tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
    tput setaf 5; echo "Old Server Port: " ${currentPort} ; tput setaf 9;
    tput setaf 6; echo "New Server Port: " ${setCurrentPort} ; tput setaf 9;
    tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
    read -p "Do you wish to continue with these changes? (y=Yes, n=No):" confirmServerPortChange
    echo ""
    #if y, then continue, else cancel
    if [ "$confirmServerPortChange" == "y" ]; then
        write_config_and_restart
    else
        echo "Canceled the changing of Server Port for Valheim - because Loki sucks"
        sleep 3
        clear
    fi
}

function change_local_world_name() {
    echo ""
    echo "Not sure if I should allow people to do this"
    echo "Follow the wiki, if you feel the need to change your world name"
    echo "https://github.com/Nimdy/Dedicated_Valheim_Server_Script/wiki/Migrate-Valheim-Map-Data-from-server-to-server"
    echo "I fear to many people will end up breaking their servers, if I add this now"
    echo "Don't you have some bees to go check on?"
    echo ""
}

function change_server_access_password() {

    get_current_config
    print_current_config
    set_config_defaults
    echo ""
    tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
    tput setaf 2; echo "---------------Set New Server Access Password---------------" ; tput setaf 9;
    tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
    tput setaf 1; echo "Now for Loki, please follow instructions" ; tput setaf 9;
    tput setaf 1; echo "Valheim requires a UNIQUE password 6 characaters or longer" ; tput setaf 9;
    tput setaf 1; echo "UNIQUE means Password can not match Public and World Names" ; tput setaf 9;
    tput setaf 1; echo "Do not use SPECIAL characters:" ; tput setaf 9;
    tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
    tput setaf 5; echo "Current Public Display Name:" ${currentDisplayName} ; tput setaf 9;
    tput setaf 5; echo "Current World Name:" ${currentWorldName} ; tput setaf 9;
    tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
    tput setaf 2; echo "Current Access Password: ${currentPassword} " ; tput setaf 9;
    tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
    while true; do
        tput setaf 1; echo "This password must be 5 Characters or more" ; tput setaf 9;
        tput setaf 1; echo "At least one number, one uppercase letter and one lowercase letter" ; tput setaf 9;
        tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
        tput setaf 2; echo "Good Example: Viking12" ; tput setaf 9;
        tput setaf 1; echo "Bad Example: Vik!" ; tput setaf 9;
        tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
        read -p "Enter Password to Enter your Valheim Server: " setCurrentPassword
        tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
        [[ ${#setCurrentPassword} -ge 5 && "$setCurrentPassword" == *[[:lower:]]* && "$setCurrentPassword" == *[[:upper:]]* && "$setCurrentPassword" =~ ^[[:alnum:]]+$ ]] && break
        tput setaf 2; echo "Password not accepted - Too Short, Special Characters" ; tput setaf 9;
        tput setaf 2; echo "I swear to LOKI, you better NOT use Special Characters" ; tput setaf 9;
    done
    echo ""
    tput setaf 5; echo "Old Server Access Password:" ${currentPassword} ; tput setaf 9;
    tput setaf 5; echo "New Server Access Password:" ${setCurrentPassword} ; tput setaf 9;
    read -p "Do you wish to continue with these changes? (y=Yes, n=No):" confirmServerAccessPassword
    #if y, then continue, else cancel
    if [ "$confirmServerAccessPassword" == "y" ]; then
        write_config_and_restart
    else
        echo "Canceled the renaming of Public Valheim Server Display Name - because Loki sucks"
        sleep 3
        clear
    fi
}


admin_valheim_config_edit(){
echo ""
echo -ne "
$(ColorOrange '------------Change Valheim Startup Config File--------------')
$(ColorOrange '-')$(ColorGreen ' 1)') Change Public Display Name
$(ColorOrange '-')$(ColorGreen ' 2)') Change Default Server Port
$(ColorOrange '-')$(ColorGreen ' 3)') Change Local World Name
$(ColorOrange '-')$(ColorGreen ' 4)') Change Server Access Password
$(ColorOrange '------------------------------------------------------------')
$(ColorOrange '-')$(ColorGreen ' 0)') Go to Admin Tools Menu
$(ColorOrange '-')$(ColorGreen ' 00)') Go to Main Menu
$(ColorOrange '------------------------------------------------------------')
$(ColorPurple 'Choose an option:') "
        read a
        case $a in
	        1) change_public_display_name ; admin_valheim_config_edit ;; 
          2) change_default_server_port ; admin_valheim_config_edit ;;
	        3) change_local_world_name ; admin_valheim_config_edit ;;
          4) change_server_access_password ; admin_valheim_config_edit ;;
        0) admin_tools_menu ; admin_tools_menu ;;
		  00) menu ; menu ;;
		    *)  echo -ne " $(ColorRed 'Wrong option.')" ; tech_support ;;
        esac
}
########################################################################
####################END CHANGE VALHEIM START CONFIG#####################
########################################################################




########################################################################
#######################Display Main Menu System#########################
########################################################################

menu() {
  clear
  echo ""
  echo -ne "
  $(ColorOrange '╔═════════════════════════════════════════╗')
  $(ColorOrange '║~~~-ZeroBandwidths Easy Valheim Menu-~~~~║')
  $(ColorOrange '╠═════════════════════════════════════════╝')
  $(ColorOrange '║ Welcome Viking!')
  $(ColorOrange '║ open to improvements')
  $(ColorOrange '║ Beware Loki hides within this script')
  $(ColorOrange '╚ ')${mversion} 
  $(ColorOrange '----------Check for Script Updates---------')
  $(ColorOrange '-')$(ColorGreen ' 1)') Check for Menu Script Updates
  $(ColorOrange '-----------Valheim Server Commands---------')
  $(ColorOrange '-')$(ColorGreen ' 2)') Server Admin Tools 
  $(ColorOrange '-')$(ColorGreen ' 3)') Tech Support Tools
  $(ColorOrange '-')$(ColorGreen ' 4)') Install Valheim Server
  $(ColorOrange '-----------------Mods Menu-----------------')
  $(ColorOrange '-')$(ColorGreen ' 5)') Coming Soon
  $(ColorOrange '-------------------------------------------')
  $(ColorGreen ' 0)') Exit
  $(ColorOrange '-------------------------------------------')
  $(ColorPurple 'Choose an option:') "
  read a
  case $a in
    1) script_check_update ; menu ;;
		2) admin_tools_menu ; menu ;;
		3) tech_support ; menu ;;
		4) server_install_menu ; menu ;;
		5) mods_menu ; menu ;;
    0) exit 0 ;;
    *)  echo -ne " $(ColorRed 'Wrong option.')" ; menu ;;
  esac
}

# Call the menu function
menu

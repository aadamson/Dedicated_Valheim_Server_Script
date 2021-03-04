#!/bin/bash
#
# This is a rather minimal example Argbash potential
# Example taken from http://argbash.readthedocs.io/en/stable/example.html
#
# ARG_OPTIONAL_BOOLEAN([interactive],[i],[Use interactive mode])
# ARG_OPTIONAL_SINGLE([backup_path],[o],[Path to store backups])
# ARG_OPTIONAL_SINGLE([world_path],[w],[Path containing worlds to be backed up])
# ARG_OPTIONAL_SINGLE([install_path],[p],[Path containing Valheim installation])
# ARG_HELP([The general script's help msg])
# ARGBASH_GO()
# needed because of Argbash --> m4_ignore([
### START OF CODE GENERATED BY Argbash v2.9.0 one line above ###
# Argbash is a bash code generator used to get arguments parsing right.
# Argbash is FREE SOFTWARE, see https://argbash.io for more info
# Generated online byhttps://argbash.io/generate

set -e

die()
{
	local _ret="${2:-1}"
	test "${_PRINT_HELP:-no}" = yes && print_help >&2
	echo "$1" >&2
	exit "${_ret}"
}


begins_with_short_option()
{
	local first_option all_short_options='iowph'
	first_option="${1:0:1}"
	test "$all_short_options" = "${all_short_options/$first_option/}" && return 1 || return 0
}

# THE DEFAULTS INITIALIZATION - OPTIONALS
_arg_interactive="off"
_arg_backup_path="/home/steam/backups"
_arg_world_path="/home/steam/.config/unity3d/IronGate/Valheim/worlds"
_arg_install_path="/home/steam/valheimserver"


print_help()
{
	printf '%s\n' "The general script's help msg"
	printf 'Usage: %s [-i|--(no-)interactive] [-o|--backup_path <arg>] [-w|--world_path <arg>] [-p|--install_path <arg>] [-h|--help]\n' "$0"
	printf '\t%s\n' "-i, --interactive, --no-interactive: Use interactive mode (off by default)"
	printf '\t%s\n' "-o, --backup_path: Path to store backups (no default)"
	printf '\t%s\n' "-w, --world_path: Path containing worlds to be backed up (no default)"
	printf '\t%s\n' "-p, --install_path: Path containing Valheim installation (no default)"
	printf '\t%s\n' "-h, --help: Prints help"
}


parse_commandline()
{
	while test $# -gt 0
	do
		_key="$1"
		case "$_key" in
			-i|--no-interactive|--interactive)
				_arg_interactive="on"
				test "${1:0:5}" = "--no-" && _arg_interactive="off"
				;;
			-i*)
				_arg_interactive="on"
				_next="${_key##-i}"
				if test -n "$_next" -a "$_next" != "$_key"
				then
					{ begins_with_short_option "$_next" && shift && set -- "-i" "-${_next}" "$@"; } || die "The short option '$_key' can't be decomposed to ${_key:0:2} and -${_key:2}, because ${_key:0:2} doesn't accept value and '-${_key:2:1}' doesn't correspond to a short option."
				fi
				;;
			-o|--backup_path)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_backup_path="$2"
				shift
				;;
			--backup_path=*)
				_arg_backup_path="${_key##--backup_path=}"
				;;
			-o*)
				_arg_backup_path="${_key##-o}"
				;;
			-w|--world_path)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_world_path="$2"
				shift
				;;
			--world_path=*)
				_arg_world_path="${_key##--world_path=}"
				;;
			-w*)
				_arg_world_path="${_key##-w}"
				;;
			-p|--install_path)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_install_path="$2"
				shift
				;;
			--install_path=*)
				_arg_install_path="${_key##--install_path=}"
				;;
			-p*)
				_arg_install_path="${_key##-p}"
				;;
			-h|--help)
				print_help
				exit 0
				;;
			-h*)
				print_help
				exit 0
				;;
			*)
				_PRINT_HELP=yes die "FATAL ERROR: Got an unexpected argument '$1'" 1
				;;
		esac
		shift
	done
} 

# START OF OUR SCRIPT
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# shellcheck source=./colors.sh
source "${DIR}/colors.sh"

########################################################################
#########################Backup Valheim Server##########################
########################################################################
function restore_world_data() {
  parse_commandline "$@"

  #init empty array
  declare -a backups

  backupPath="${_arg_backup_path}"
  worldpath="${_arg_world_path}"
  valheimInstallPath="${_arg_install_path}"

  #loop through backups and put in array
  for file in ${backupPath}/*.tgz
  do
    backups=(${backups[*]} "$file")
  done;

  #counter index
  bIndex=1
  for item in "${backups[@]}";do
    #print option [index]> [file name]
    basefile=$(basename "$item")
    echo "$bIndex> ${basefile} "
    #increment
    bIndex=$((bIndex+1))
  done


  #show confirmation message
  if [ "${_arg_interactive}" = "on" ]; then
    #promt user for index
    tput setaf 2; echo "Select Backup File you wish to restore" ; tput setaf 9;
    read -p "" selectedIndex
    restorefile=$(basename "${backups[$selectedIndex-1]}")

    echo -ne "
    $(ColorRed '------------------------------------------------------------')
    $(ColorGreen 'Restore '${restorefile}' ?')
    $(ColorGreen 'Are you sure you want to do this? ')
    $(ColorOrange 'Remember to match world name with '${valheimInstallPath}'/start_valheim.sh')
    $(ColorOrange 'The param for -world "worldname" much match restore file worldname.db and worldname.fwl')
    $(ColorGreen 'Press y (for yes) or n (for no)') "

    #read user input confirmation
    read -p "" confirmBackupRestore
  else
    confirmBackupRestore="y"
    selectedIndex=$((bIndex-1))
    restorefile=$(basename "${backups[$selectedIndex-1]}")
  fi
  #if y, then continue, else cancel
  if [ "$confirmBackupRestore" == "y" ]; then
    #stop valheim server
    tput setaf 1; echo "Stopping Valheim Server" ; tput setaf 9;
    systemctl stop valheimserver.service
    tput setaf 2; echo "Valheim Services successfully Stopped" ; tput setaf 9;

    #give it a few
    sleep 5

    #copy backup to worlds folder
    tput setaf 2; echo "Copying ${backups[$selectedIndex-1]} to ${worldpath}/" ; tput setaf 9;
    cp ${backups[$selectedIndex-1]} ${worldpath}/

    #untar
    tput setaf 2; echo "Unpacking ${worldpath}/${restorefile}" ; tput setaf 9;
    tar xzf ${worldpath}/${restorefile} --directory ${worldpath}/  
    chown -Rf steam:steam ${worldpath}
    rm  ${worldpath}/*.tgz
    tput setaf 2; echo "Starting Valheim Services" ; tput setaf 9;
    tput setaf 2; echo "This better work Loki!" ; tput setaf 9;
    systemctl start valheimserver.service
  else
    tput setaf 2; echo "Canceling restore process because Loki sucks" ; tput setaf 9;
  fi
}

restore_world_data "$@"

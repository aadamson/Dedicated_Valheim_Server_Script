#!/bin/bash
#
# This is a rather minimal example Argbash potential
# Example taken from http://argbash.readthedocs.io/en/stable/example.html
#
# ARG_OPTIONAL_BOOLEAN([interactive],[i],[Use interactive mode])
# ARG_OPTIONAL_SINGLE([backup_path],[o],[Path to store backups])
# ARG_OPTIONAL_SINGLE([world_path],[w],[Path containing worlds to be backed up])
# ARG_HELP([The general script's help msg])
# ARGBASH_GO()
# needed because of Argbash --> m4_ignore([
### START OF CODE GENERATED BY Argbash v2.9.0 one line above ###
# Argbash is a bash code generator used to get arguments parsing right.
# Argbash is FREE SOFTWARE, see https://argbash.io for more info
# Generated online by https://argbash.io/generate

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
	local first_option all_short_options='iowh'
	first_option="${1:0:1}"
	test "$all_short_options" = "${all_short_options/$first_option/}" && return 1 || return 0
}

# THE DEFAULTS INITIALIZATION - OPTIONALS
_arg_interactive="off"
_arg_backup_path="/home/steam/backups"
_arg_world_path="/home/steam/.config/unity3d/IronGate/Valheim/worlds"


print_help()
{
	printf '%s\n' "The general script's help msg"
	printf 'Usage: %s [-i|--(no-)interactive] [-o|--backup_path <arg>] [-w|--world_path <arg>] [-h|--help]\n' "$0"
	printf '\t%s\n' "-i, --interactive, --no-interactive: Use interactive mode (off by default)"
	printf '\t%s\n' "-o, --backup_path: Path to store backups (no default)"
	printf '\t%s\n' "-w, --world_path: Path containing worlds to be backed up (no default)"
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
function backup_world_data() {
  parse_commandline "$@"

  backupPath="${_arg_backup_path}"
  worldpath="${_arg_world_path}"

  echo ""
  echo ""
  if [ "${_arg_interactive}" = "on" ]; then
    #read user input confirmation
    tput setaf 1; echo "This will stop and start Valheim Services." ; tput setaf 9;
    tput setaf 1; echo "Are you okay with this? (y=Yes, n=No)" ; tput setaf 9;
    read -p "Press y or n:" confirmBackup
  else
    confirmBackup="y"
  fi
  # if y, then continue, else cancel
  if [ "$confirmBackup" == "y" ]; then
    ## Get the current date as variable.
    TODAY="$(date +%Y-%m-%d-%T)"
    tput setaf 5; echo "Checking to see if backup directory is created" ; tput setaf 9;
    tput setaf 5; echo "If not, one will be created" ; tput setaf 9;

    dldir=$backupPath
    [ ! -d "$dldir" ] && mkdir -p "$dldir"
    sleep 1

    ## Clean up files older than 2 weeks. Create a new backup.
    tput setaf 1; echo "Cleaning up old backup files. Older than 2 weeks" ; tput setaf 9;
    find $backupPath/* -mtime +14 -type f -delete
    tput setaf 2; echo "Cleaned up better than Loki" ; tput setaf 9;
    sleep 1

    ## Tar Section. Create a backup file, with the current date in its name.
    ## Add -h to convert the symbolic links into a regular files.
    ## Backup some system files, also the entire `/home` directory, etc.
    ##--exclude some directories, for example the the browser's cache, `.bash_history`, etc.
    #stop valheim server
    tput setaf 1; echo "Stopping Valheim Server for clean backups" ; tput setaf 9;
    systemctl stop valheimserver.service
    tput setaf 1; echo "Stopped" ; tput setaf 9;
    tput setaf 1; echo "Making tar file of world data" ; tput setaf 9;
    tar czf $backupPath/valheim-backup-$TODAY.tgz -C $worldpath .
    tput setaf 2; echo "Process complete!" ; tput setaf 9;
    sleep 1
    tput setaf 2; echo "Restarting the best Valheim Server in the world" ; tput setaf 9;
    systemctl start valheimserver.service
    tput setaf 2; echo "Valheim Server Service Started" ; tput setaf 9;
    echo ""
    tput setaf 2; echo "Setting permissions for steam on backup file" ; tput setaf 9;
    chown -Rf steam:steam ${backupPath}
    tput setaf 2; echo "Process complete!" ; tput setaf 9;
    echo ""
  else 
    tput setaf 3; echo "Backuping up of the world files .db and .fwl canceled" ; tput setaf 9;
  fi
}

backup_world_data "$@"

#!/bin/bash
#
# This is a rather minimal example Argbash potential
# Example taken from http://argbash.readthedocs.io/en/stable/example.html
#
# ARG_OPTIONAL_BOOLEAN([interactive],[i],[Use interactive mode])
# ARG_OPTIONAL_SINGLE([install_path],[p],[Path containing Valheim installation])
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
	local first_option all_short_options='iph'
	first_option="${1:0:1}"
	test "$all_short_options" = "${all_short_options/$first_option/}" && return 1 || return 0
}

# THE DEFAULTS INITIALIZATION - OPTIONALS
_arg_interactive="off"
_arg_install_path="/home/steam/valheimserver"


print_help()
{
	printf '%s\n' "The general script's help msg"
	printf 'Usage: %s [-i|--(no-)interactive] [-p|--install_path <arg>] [-h|--help]\n' "$0"
	printf '\t%s\n' "-i, --interactive, --no-interactive: Use interactive mode (off by default)"
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
#############Install Official Update of Valheim Updates#################
########################################################################
function continue_with_valheim_update_install() {
  clear
  echo ""
  echo -ne "
  $(ColorOrange '-----------------Installing Valheim Updates-----------------')
  $(ColorRed '------------------------------------------------------------')"
  if [ "${_arg_interactive}" = "on" ]; then
    echo ""
    tput setaf 2; echo "A NEW update was found!" ; tput setaf 9;
    tput setaf 2; echo "You are about to apply Official Valheim Updates" ; tput setaf 9;
    tput setaf 2; echo "You are you sure y(YES) or n(NO)?" ; tput setaf 9;
    echo -ne "
    $(ColorRed '------------------------------------------------------------')"
    echo ""
    read -p "Please confirm:" confirmOfficialUpdates
  else
    confirmOfficialUpdates="y"
  fi

  #if y, then continue, else cancel
  if [ "$confirmOfficialUpdates" == "y" ]; then
    tput setaf 2; echo "Using Thor's Hammer to apply Official Updates!" ; tput setaf 9;
    /home/steam/steamcmd +login anonymous +force_install_dir "${_arg_install_path}" +app_update 896660 validate +exit
    chown -R steam:steam "${_arg_install_path}"
    echo ""
  else
    echo "Canceling all Official Updates for Valheim Server - because Loki sucks"
    sleep 3
    clear
  fi
}

########################################################################
######################beta updater for Valheim##########################
########################################################################
function check_apply_server_updates_beta() {
  parse_commandline "$@"

  echo ""
  echo "Downloading Official Valheim Repo Log Data for comparison only"
  [ ! -d /opt/valheimtemp ] && mkdir -p /opt/valheimtemp

  /home/steam/steamcmd +login anonymous +force_install_dir /opt/valheimtemp +app_update 896660 validate +exit
  sed -e 's/[\t ]//g;/^$/d' /opt/valheimtemp/steamapps/appmanifest_896660.acf > appmanirepo.log
  repoValheim=$(sed -n '11p' appmanirepo.log)
  echo "Official Valheim-: $repoValheim"
  sed -e 's/[\t ]//g;/^$/d' ${_arg_install_path}/steamapps/appmanifest_896660.acf > appmanilocal.log
  localValheim=$(sed -n '11p' appmanilocal.log)
  echo "Local Valheim Ver: $localValheim"

  if [ "$repoValheim" == "$localValheim" ]; then
    echo "No new Updates found"
    echo "Cleaning up TEMP FILES"
    rm -Rf /opt/valheimtemp
    rm appmanirepo.log
    rm appmanilocal.log
    sleep 2
  else
    echo "Update Found kicking process to Odin for updating!"
    sleep 2
    continue_with_valheim_update_install
    echo ""
  fi
  echo ""
}

check_apply_server_updates_beta "$@"
#
# deta
#
# Copyright (c) 2011-2014 David Persson
#
# Distributed under the terms of the MIT License.
# Redistributions of files must retain the above copyright notice.
#
# @COPYRIGHT 2011-2014 David Persson <nperson@gmx.de>
# @LICENSE   http://www.opensource.org/licenses/mit-license.php The MIT License
# @LINK      http://github.com/davidpersson/deta
#

# @FUNCTION: msg*
# @USAGE: <message> [replacement0..]
# @DESCRIPTION:
# Outputs status messages honoring QUIET flag.
msg()     { if [[ $QUIET != "y" ]]; then _msg ""     "$@"; fi }
msgok()   { if [[ $QUIET != "y" ]]; then _msg "ok"   "$@"; fi }
msgskip() { if [[ $QUIET != "y" ]]; then _msg "skip" "$@"; fi }
msgdry()  { if [[ $QUIET != "y" ]]; then _msg "dry"  "$@"; fi }
msgwarn() { _msg "warn" "$@" >&2; }
msgfail() { _msg "fail" "$@" >&2; }

# @FUNCTION: _msg
# @USAGE: <status> <message> [replacement0..]
# @DESCRIPTION:
# Outputs status messages.
_msg() {
	local status=$1
	local message=$2
	shift 2

	local IFS=""
	printf "[\e[1;34m%s\e[0m] [%5s] \e[1;32m%s\e[0m\n" \
		"$(date +%T)" \
		"$status" \
		"$(printf "$message" $@)"
}

msgok "Module %s loaded." "core"

# @FUNCTION: role
# @USAGE: <role>
# @DESCRIPTION:
# Maps an env (left) to role provided
# to this function (right). Detects role by:
# 1. Checking all available envs for a variable i.e.
#    DEV_<role>="y" will select DEV as the role.
# 2. Prompting the user to select from available env.
role() {
	local pair=$(set | grep -m 1 "_$1=y" );

	if [[ -n $pair ]];  then
		 _env_to_role ${pair%_*} $1
	else
		for env_ in $(set | grep -E "^[A-Z]+_HOST="); do
			local avail+="${env_%_*} "
		done
		local PS3="Please select an env to map to role $1: "
		select env in $avail; do
			_env_to_role $env $1
			break
		done
	fi
	msgok "Using role %s." $1
}

# @FUNCTION: _env_to_role
# @USAGE: <env> <role>
# @DESCRIPTION:
# Maps all variables from env to role.
_env_to_role() {
	local IFS=$'\n'
	for c in $(set | grep -E "^$1_"); do
		eval ${c/$1_/$2_}
	done
	msgok "Mapped env %s to role %s." $@
}

# @FUNCTION: dry
# @DESCRIPTION:
# Checks if dryrun is enabled and displays warning message.
dry() {
	if [[ $DRYRUN != "y" ]]; then
		msgwarn "Dry run is NOT enabled! Press STRG+C to abort."
		msg "Starting in 3 seconds."
		echo -n "  "
		for I in {1..3}; do
			echo -n '.'
			sleep 1
		done
		echo
	fi
}

# @VARIABLE DEFERRED
# @DESCRIPTION
# Used within defer() and _defer() functions as a
# stack. Don't access directly.
DEFERRED=()

# @FUNCTION: defer
# @USAGE: <command>
# @DESCRIPTION:
# Queues given command to execute it later. Registers
# handler first time it is used.
defer() {
	if [[ -z ${DEFERRED-} ]]; then
		msg "Trapping %s signal." "EXIT"
		trap _defer EXIT
	fi
	DEFERRED[${#DEFERRED[*]}]=$@
}

# @FUNCTION: _defer
# @DESCRIPTION:
# Supposed to be registered as a handler for trapping EXIT
# signals. Executes commands on DEFERRED stack.
_defer() {
	for command in "${DEFERRED[@]}"; do
		msg "Executing %s." "$command"
		eval $command
	done
}


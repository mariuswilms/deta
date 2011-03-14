#
# deta
#
# Copyright (c) 2011 David Persson
#
# Distributed under the terms of the MIT License.
# Redistributions of files must retain the above copyright notice.
#
# @COPYRIGHT 2011 David Persson <nperson@gmx.de>
# @LICENSE   http://www.opensource.org/licenses/mit-license.php The MIT License
# @LINK      http://github.com/davidpersson/deta
#

printf "[%5s] Module %s loaded.\n" "ok" "core"

# @FUNCTION: role
# @USAGE: [role]
# @DESCRIPTION:
# Maps an env (left) to role provided
# to this function (right). Detects role by:
# 1. Checking all available envs for a variable i.e.
#    DEV_[role]="y" will select DEV as the role.
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
	printf "[%5s] Using role %s.\n" "ok" $@
}

# @FUNCTION: _env_to_role
# @USAGE: [env] [role]
# @DESCRIPTION:
# Maps all variables from env to role.
_env_to_role() {
	local IFS=$'\n'
	for c in $(set | grep -E "^$1_"); do
		eval ${c/$1_/$2_}
	done
	printf "[%5s] Mapped env %s to role %s.\n" "ok" $@
}

# @FUNCTION: dry
# @USAGE:
# @DESCRIPTION:
# Checks if dryrun is enabled and displays warning message.
dry() {
	if [[ $DRYRUN != "y" ]]; then
		printf "[%5s] Dry run is NOT enabled! Press STRG+C to abort.
			Starting in 3 seconds" "warn"
		for I in {1..3}; do
			echo -n '.'
			sleep 1
		done
		echo
	fi
}

# @VARIABLE ONEXIT
# @DESCRIPTION
# Used within onexit() and _onexit() functions as a
# stack. Don't access directly.
ONEXIT=()

# @FUNCTION: onexit
# @USAGE: [command]
# @DESCRIPTION:
# Queues given command to execute it later. Registers
# handler first time it is used.
onexit() {
	if [[ -z ${ONEXIT-} ]]; then
		printf "[%5s] Trapping %s signal.\n" "" "EXIT"
		trap _onexit EXIT
	fi
	ONEXIT[${#ONEXIT[*]}]=$@
}

# @FUNCTION: _onexit
# @USAGE:
# @DESCRIPTION:
# Supposed to be registered as a handler for trapping EXIT
# signals. Executes commands on ONEXIT stack.
_onexit() {
	for command in "${ONEXIT[@]}"; do
		printf "[%5s] Executing %s.\n" "" "$command"
		eval $command
	done
}


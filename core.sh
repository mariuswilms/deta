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

# @FUNCTION: use_scope
# @USAGE: [scope]
# @DESCRIPTION:
# Maps an env (left) to scope provided
# to this function (right). Detects scope by:
# 1. Checking all available envs for a variable i.e.
#    DEV_[scope]="y" will select DEV as the env.
# 2. Prompting the user to select from available env.
use_scope() {
	local PAIR=$(set | grep -m 1 "_$1=y" );

	if [[ -n $PAIR ]];  then
		 _env_to_scope ${PAIR%_*} $1
	else
		for ENV_ in $(set | grep -E "^[A-Z]+_HOST="); do
			local AVAIL+="${ENV_%_*} "
		done
		local PS3="Please select an env to map to scope $1: "
		select ENV in $AVAIL; do
			_env_to_scope $ENV $1
			break
		done
	fi
	printf "[%5s] Using scope %s.\n" "ok" $@
}

# @FUNCTION: _env_to_scope
# @USAGE: [env] [scope]
# @DESCRIPTION:
# Maps all variables from env to scope.
_env_to_scope() {
	local IFS=$'\n'
	for C in $(set | grep -E "^$1_"); do
		eval ${C/$1_/$2_}
	done
	printf "[%5s] Mapped env %s to scope %s.\n" "ok" $@
}


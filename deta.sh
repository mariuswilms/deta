#!/bin/sh
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

# -----------------------------------------------------------
# Environment settings
# -----------------------------------------------------------
set -o nounset
set -o errexit

if [[ $(uname) = "Darwin" ]]; then
	# Disable copying of resource forks on Darwin.
	export COPYFILE_DISABLE="true"
fi

# -----------------------------------------------------------
# Libraries
# -----------------------------------------------------------
if [[ -L $0 ]]; then
	SELF=$(readlink -n $0)
else
	SELF=$0
fi
DETA=$(dirname $SELF)

# -----------------------------------------------------------
# Options & Argument parsing
# -----------------------------------------------------------
QUIET="n"
DRYRUN="n"

while getopts ":q:n:d" OPT; do
	case $OPT in
		q)
			QUIET="y"
			;;
		n)
			DRYRUN="y"
			;;
		d)
			set -x
			;;
		\?)
			printf "Invalid option '%s'." $OPTARG
			exit 1
			;;
	esac
	shift
done

if [ $# == 0 ]; then
	echo "Invalid usage."
	exit 1
fi
TASK="$1"

# -----------------------------------------------------------
# Main
# -----------------------------------------------------------
if [[ $QUIET != 'y' ]]; then
	echo "========================================================="
	echo "deta 0.1"
	echo
fi
if [[ $DRYRUN != "y" ]]; then
	printf "[%5s] Dry run is NOT enabled! Press STRG+C to abort.
        Starting in 5 seconds" "warn"
	for I in 1 2 3 4 5; do
		sleep 1
		echo -n '.'
	done
	echo
fi
if [[ $QUIET != 'y' ]]; then
	printf "[%5s] Executing task %s.\n" "ok" $TASK
fi

source $TASK

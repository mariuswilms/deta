#!/bin/bash
#
# DETA
#
# Copyright (c) 2011-2012 David Persson
#
# Distributed under the terms of the MIT License.
# Redistributions of files must retain the above copyright notice.
#
# @COPYRIGHT 2011-2012 David Persson <nperson@gmx.de>
# @LICENSE   http://www.opensource.org/licenses/mit-license.php The MIT License
# @LINK      http://github.com/davidpersson/deta
#

# -----------------------------------------------------------
# Environment settings
# -----------------------------------------------------------
set -o nounset
set -o errexit

if [[ $(uname) == "Darwin" ]]; then
	# Disable copying of resource forks on Darwin.
	export COPYFILE_DISABLE="true"
fi

# -----------------------------------------------------------
# Paths
# -----------------------------------------------------------
CONFIG_PATH=$(pwd)

if [[ -L $0 ]]; then
	DETA=$(dirname $(readlink -n $0))
else
	DETA=$(dirname $0)
fi

# -----------------------------------------------------------
# Standard Options & Argument parsing
# -----------------------------------------------------------
QUIET="n"
DRYRUN="n"
VERSION="0.3.0-head"

while getopts ":qndV:c:" OPT; do
	case $OPT in
		c)  CONFIG_PATH=$OPTARG;;
		q)  QUIET="y";;
		n)  DRYRUN="y";;
		d)  set -x;;
		V)  echo "DETA $VERSION by David Persson."; exit;;
		:)  printf "Option '%s' requires an argument.\n" $OPTARG; exit 1;;
		\?) printf "Invalid option '%s'.\n" $OPT; exit 1;;
	esac
done
shift $(expr $OPTIND - 1)

if [[ $# == 0 ]]; then
	echo "Usage: deta.sh [options] <task>"
	echo
	echo "Tasks:"
	for file in $(find . -type f -name '*.sh'); do
		echo "  ${file##./}"
	done
	echo
	echo "Options:"
	echo "  -c <path> Path to the directory holding configurations, defaults to current directory."
	echo "  -n        Enable dry-run."
	echo "  -V        Show current version."
	echo "  -d        Enable debug output."
	echo "  -q        Quiet mode, surpress most output except errors."
	echo
	exit 1
fi

TASK="$1"
shift

# -----------------------------------------------------------
# Load standard module.
# -----------------------------------------------------------
source $DETA/core.sh
# We can now start using the messaging functions as they've
# just been loaded from core.sh.

# -----------------------------------------------------------
# Configuration
# -----------------------------------------------------------
set +o errexit
for file in $CONFIG_PATH/*.conf 2> /dev/null); do
	source $file
	msgok "Loaded %s." ${file##./}
done
set -o errexit

# -----------------------------------------------------------
# Task
# -----------------------------------------------------------
msg "Executing task %s." $TASK
source $TASK

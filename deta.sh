#!/bin/bash
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

if [[ $(uname) == "Darwin" ]]; then
	# Disable copying of resource forks on Darwin.
	export COPYFILE_DISABLE="true"
fi

# -----------------------------------------------------------
# Paths
# -----------------------------------------------------------
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

while getopts ":qnd" OPT; do
	case $OPT in
		q)  QUIET="y";;
		n)  DRYRUN="y";;
		d)  set -x;;
		\?) printf "Invalid option '%s'." $OPT; exit 1;;
	esac
done
shift $(expr $OPTIND - 1)

if [[ $# == 0 ]]; then
	echo "Usage: $(basename $0) [-q] [-n] [-d] TASK"
	echo
	echo "Available env configuration:"
	for file in $(ls *.conf 2> /dev/null); do
		echo " * $file"
	done
	echo
	echo "Available tasks:"
	for file in $(find . -type f -name *.sh); do
		echo " * $file"
	done
	echo
	exit 1
fi
TASK="$1"
shift

# -----------------------------------------------------------
# Header
# -----------------------------------------------------------
if [[ $QUIET != "y" ]]; then
	echo "========================================================="
	echo "DETA 0.1.0"
	echo
fi

# -----------------------------------------------------------
# Load standard module.
# -----------------------------------------------------------
source $DETA/core.sh

# -----------------------------------------------------------
# Configuration
# -----------------------------------------------------------
for file in $(ls $(pwd)/*.conf); do
	msg "Loading configuration %s." $(basename $file)
	source $file
done

# -----------------------------------------------------------
# Task
# -----------------------------------------------------------
msg "Executing task %s." $TASK
source $TASK

#!/bin/bash
#
# DETA
#
# Copyright (c) 2011 David Persson
#
# Distributed under the terms of the MIT License.
# Redistributions of files must retain the above copyright notice.
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
# Options
# -----------------------------------------------------------
QUIET="n"
DRYRUN="n"
VERBOSE="n"
VERSION="1.0.0-head"

while getopts ":qndvV:c:t:" OPT; do
	case $OPT in
		c)  CONFIG_FILE=$OPTARG;;
		t)  TASK_PATH=$OPTARG;;
		q)  QUIET="y";;
		v)  VERBOSE="y";;
		n)  DRYRUN="y";;
		d)  set -x;;
		V)  echo "DETA $VERSION by David Persson."; exit;;
		:)  printf "Option '%s' requires an argument.\n" $OPTARG; exit 1;;
		\?) printf "Invalid option '%s'.\n" $OPT; exit 1;;
	esac
done
shift $(expr $OPTIND - 1)

# -----------------------------------------------------------
# Paths and other Configurations
# ----------------------------------------------------------

for FILE in "$(pwd)/Envfile" "$(pwd)/../Envfile"; do
	if [[ -f $FILE ]]; then
		CONFIG_FILE=$FILE
		break
	fi
done
if [[ $CONFIG_FILE == "" ]]; then
	echo "No configuration file found or given."
	exit 1
fi
if [[ ! -f $CONFIG_FILE ]]; then
	echo "Configuration file is not a file; given $CONFIG_FILE"
	exit 1
fi

for DIR in "$(pwd)/bin"; do
	if [[ -d $DIR ]]; then
		TASK_PATH=$DIR
		break
	fi
done
TASK_PATH=${TASK_PATH:-$(pwd)}

if [[ -L $0 ]]; then
	DETA=$(dirname $(readlink -n $0))
else
	DETA=$(dirname $0)
fi

# -----------------------------------------------------------
# Arguments
# -----------------------------------------------------------
if [[ $# == 0 ]]; then
	echo "Usage: deta.sh [options] <task>"
	echo
	echo "Tasks:"
	for file in $(find $TASK_PATH -type f -name '*.sh'); do
		echo "  ${file##$TASK_PATH/}"
	done
	echo
	echo "Options:"
	echo "  -c <file> Path to the configuration file."
	echo "  -t <path> Path to the directory holding tasks."
	echo "  -n        Enable dry-run."
	echo "  -V        Show current version."
	echo "  -q        Quiet mode, surpress most output except errors."
	echo "  -v        Enable verbose output."
	echo "  -d        Enable debug output."
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
msginfo "Configuration file is %s." $CONFIG_FILE
msginfo "Task directory is %s." $TASK_PATH

# -----------------------------------------------------------
# Task
# -----------------------------------------------------------
msginfo "Executing task %s." ${TASK##$TASK_PATH/}
source $TASK

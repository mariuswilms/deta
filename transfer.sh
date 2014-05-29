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

msginfo "Module %s loaded." "transfer"

# @FUNCTION: download
# @USAGE: <URL> <target>
# @DESCRIPTION:
# Downloads from various sources. Implements "svn export"-like functionality
# for GIT. Automatically dearchives downloaded archives. The source URL may
# point to an archive, a repository or a single file.
download() {
	msg "Downloading %s." $1

	case $1 in
		# Partially GitHub specific
		*".zip"* | *"/zipball/"*)
			tmp=$(mktemp -d -t deta)
			defer rm -rf $tmp

			curl -# -f -L $1 --O $tmp/download.zip
			unzip $tmp/download -d $2
		;;
		# Partially GitHub specific
		*".tar.gz"* | *"/tarball/"*)
			curl -s -S -f -L $1 | tar vxz -C $2
		;;
		"git"* | *".git")
			git clone --no-hardlinks --progress --depth 1 $1 $2
		;;
		"svn://"* | *"/svn/"* | *".svn."*)
			svn export $1 $2
		;;
		# Must come after filetype-specific download strategies.
		"http://"* | "https://"*)
			curl -# -f -L $1 --O $2
		;;
		*"://"*)
			curl -# -f -L $1 --O $2
		;;
		*)
			if [[ -f $1 ]]; then
				cp -v $1 $2
			elif [[ -d $1/.git ]]; then
				git clone --no-hardlinks --progress $1 $2
			fi
		;;
	esac
}

# @FUNCTION: sync
# @USAGE: <source> <target> <ignore>
# @DESCRIPTION:
# Will rsync all directories and files from <source> to <target>. Thus files
# which have been removed in <source> will also be removed from <target>.
# Specify a whitespace separated list of patterns to ignore. Files matching the
# patterns won't be transferred from <source> to <target>.  This function has
# DRYRUN support. Symlinks are copied as symlinks.
sync() {
	if [[ $DRYRUN != "n" ]]; then
		msgdry "Pretending syncing from %s to target %s." $1 $2
	else
		msg "Syncing from %s to target %s." $1 $2
	fi
	rsync --stats -h -z -p -r --delete \
			$(_rsync_ignore "$3") \
			--links \
			--times \
			--verbose \
			--itemize-changes \
			$(_rsync_dryrun) \
			$1 $2
}

# @FUNCTION: sync_sanity
# @USAGE: <source> <target> <ignore>
# @DESCRIPTION:
# Performs sanity checks on a sync from <source> to <target>. Will ask for
# confirmation if and return 1 thus aborting the script when the errexit option
# is set. Best used right before the actual sync call. See the sync function
# for more information on behavior and arguments.
sync_sanity() {
	local backup=$DRYRUN
	DRYRUN="y"

	msgdry "Running sync sanity check."
	local out=$(sync $1 $2 "$3" 2>&1)

	DRYRUN=$backup

	set +o errexit # grep may not match anything at all.
	echo "To be changed on target:"
	echo "$out" | grep -E '^<[a-z]+.*[a-z\?].*'
	echo
	echo "To be deleted on target:"
	echo "$out" | grep deleting
	echo
	echo "To be created on target:"
	echo "$out" | grep '^c'
	echo
	set -o errexit

	read -p "Looks good? (y/N) " continue
	if [[ $continue != "y" ]]; then
		return 1
	fi
}

# @FUNCTION: _rsync_ignore
# @USAGE: <ignore>
# @DESCRIPTION:
# Takes a list of ignores and creates an argument to be passed to rsync.
_rsync_ignore() {
	local tmp=$(mktemp -t deta)

	for excluded in $1; do
		echo $excluded >> $tmp
	done
	# defer rm $tmp
	echo "--exclude-from=$tmp"
}

# @FUNCTION: _rsync_dryrun
# @DESCRIPTION:
# Creates the dryrun argument to be passed to rsync. This function
# has DRYRUN support.
_rsync_dryrun() {
	if [[ $DRYRUN != "n" ]]; then
		echo "--dry-run"
	fi
}

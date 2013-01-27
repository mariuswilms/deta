#
# deta
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

msgok "Module %s loaded." "util"

# @FUNCTION: exists_and_empty
# @USAGE: [directory]
# @DESCRIPTION:
# Ensures the provided directory is existent and empty. **USE WITH CAUTON**
# Will remove existing directories.
exists_and_empty() {
	if [ -d $1 ]; then
		msg "Removing directory %s forcefully." $1
		rm -rf $1
	fi
	msg "Creating directory %s." $1
	mkdir -p $1
}

# @FUNCTION: create_manifest
# @USAGE: [directory] [file]
# @DESCRIPTION:
# Creates a manifest from the contents of the given directory.
create_manifest() {
	msg "Creating manifest from %s in %s." $1 $2
	mtree -K md5digest -x -c -p $1 > $2
}

# @FUNCTION: fill
# @USAGE: [placeholder] [replace] [file]
# @DESCRIPTION:
# Replaces placeholders in a file with actual values.
fill() {
	msg "Replacing placeholder %s with value %s in %s." $@
	sed -i -e "s|$1|$2|g" $3

	# Workaround for older BSD versions of sed that need
	# a suffix after -i while interpreting -e as the suffix.
	if [[ -f ${3}-e ]]; then rm ${3}-e; fi
}

# @FUNCTION: clear_vcs
# @USAGE: [directory]
# @DESCRIPTION:
# Forcefully removes any directories and files needed by version control
# systems like SVN and GIT.
clear_vcs() {
	msg "Removing any VCS traces from directory %s." $1
	find $1 -type d -name .svn    | xargs rm -v -rf
	find $1 -type d -name .git    | xargs rm -v -rf
	find $1 -type f -name '.git*' | xargs rm -v
}

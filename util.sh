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

msgok "Module %s loaded." "util"

# @FUNCTION: exists_and_empty
# @USAGE: <directory>
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
# @USAGE: <directory> <file>
# @DESCRIPTION:
# Creates a manifest from the contents of the given directory.
create_manifest() {
	msg "Creating manifest from %s in %s." $1 $2
	mtree -K md5digest -x -c -p $1 > $2
}

# @FUNCTION: fill
# @USAGE: <placeholder> <replace> <file>
# @DESCRIPTION:
# Replaces placeholders in a file with actual values.
fill() {
	msg "Replacing placeholder %s with value %s in %s." $1 "$2" $3
	sed -i -e "s|$1|$2|g" $3

	# Workaround for older BSD versions of sed that need
	# a suffix after -i while interpreting -e as the suffix.
	if [[ -f ${3}-e ]]; then rm ${3}-e; fi
}

# @FUNCTION: apply_patches
# @USAGE: <path to patchfile 1> [path to patchfile 2] [...]
# @DESCRIPTION:
# Applies a set of patches. Strips the first prefix off by default.
apply_patches() {
	for file in "$@"; do
		msg "Applying patch %s." $file
		patch -p1 < $file
	done
}

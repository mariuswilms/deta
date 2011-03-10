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

printf "[%5s] Module %s loaded.\n" "ok" "util"

# @FUNCTION: exists_and_empty
# @USAGE: [directory]
# @DESCRIPTION:
# Ensures the provided directory is existent and empty. **USE WITH CAUTON**
# Will remove existing directories.
exists_and_empty() {
	if [ -d $1 ]; then
		printf "[%5s] Removing directory %s forcefully.\n" "" $1
		rm -rf $1
	fi
	printf "[%5s] Creating directory %s.\n" "" $1
	mkdir -p $1
}

# @FUNCTION: create_manifest
# @USAGE: [directory] [file]
# @DESCRIPTION:
# Creates a manifest from the contents of the given directory.
create_manifest() {
	printf "[%5s] Creating manifest from %s in %s.\n" "" $1 $2
	mtree -K md5digest -x -c -p $1 > $2
}

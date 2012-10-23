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

# This task restores backups from a source to a default temporary directory.

source $DETA/backup.sh

role SOURCE # The env where the backups are.

TMP=$(mktemp -d -t deta)
defer rm -rf $TMP

PS3="Select a previous backup to restore from (most recent first): "
select file in $(ls -t $SOURCE_PATH/*.tar.gpg); do
	dearchive $file $TMP
	break
done

msgok "Restored backup mounted in %s." $TMP


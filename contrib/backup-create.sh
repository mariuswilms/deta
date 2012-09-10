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

# This task backups source to target, where target could
# be a dedicated backup environment.

source $DETA/backup.sh
source $DETA/transfer.sh
source $DETA/invoke.sh

role SOURCE # The env to backup from.
role TARGET # The env to store the backup in.

dry

TMP=$(mktemp -d -t deta)
defer rm -rf $TMP

PS3="Backup to base onto (most recent first): "
select file in $(ls -t $TARGET_PATH/*) "none"; do
	if [[ $file == "none" ]]; then
		break
	fi
	dearchive $file $TMP
	break
done

# Uncomment and modify to run tasks on source.
# run_ssh $SOURCE_HOST <<-SESSION
# 	cd $SOURCE_PATH/scripts
# 	./deta db/dump.sh
# SESSION

sync_sanity "$SOURCE_HOST:$SOURCE_PATH/*" $TMP "$SOURCE_IGNORE"

set +o errexit
sync "$SOURCE_HOST:$SOURCE_PATH/*" $TMP "$SOURCE_IGNORE"
set -o errexit

archive $TMP $TARGET_PATH ${SOURCE_HOST}-${SOURCE_NAME}

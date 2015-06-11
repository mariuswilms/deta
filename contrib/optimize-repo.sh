#
# deta
#
# Copyright (c) 2011 David Persson
#
# Distributed under the terms of the MIT License.
# Redistributions of files must retain the above copyright notice.
#

# This task will optimize your local GIT repository.

role THIS

cd $THIS_PATH

if [[ ! -d .git ]]; then
	msgfail "Not a GIT repository."
	exit 1
fi

du -hs .git

git prune
git gc --aggressive
git prune-packed
git repack -a

du -hs .git

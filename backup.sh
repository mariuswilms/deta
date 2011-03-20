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

printf "[%5s] Module %s loaded.\n" "ok" "backup"

# @FUNCTION: archive
# @USAGE: [source dir] [target dir] [label prefix]
# @DESCRIPTION:
# Archives source directory by creating a labeled archive in target directory.
# Symlinks are *not* dereferenced when creating the archive.
archive() {
	local label=${3}-$(date +%Y-%m-%d-%H-%M)

	printf "[%5s] Creating and verifying archive from %s.\n" "" $1
	cd $1
	tar -Wp -cf $2/$label.tar *
	cd -

	printf "[%5s] Encrypting archive.\n" ""
	read -p "Encrypt for: " user
	gpg -v -z 0 -r $user --encrypt $2/$label.tar

	printf "[%5s] Verifying encrypted archive.\n" ""
	gpg -v -ba -u $user $2/$label.tar.gpg
	gpg -v --verify $2/$label.tar.gpg.asc

	rm -v $2/$label.tar.gpg.asc
	rm -v $2/$label.tar

	local size_before=$(du -hs $1 | awk '{ print $1 }')
	local size_after=$(ls -lah $2/$label.tar.gpg | awk '{ print $5 }')
	printf "[%5s] Archive created at %s (%s->%s).\n" "ok" "$2/$label.tar.gpg" $size_before $size_after
}

# @FUNCTION: dearchive
# @USAGE: [source file] [target dir]
# @DESCRIPTION:
# Decrypts and unpacks archive [source] to directory [target].
dearchive() {
	printf "[%5s] Decrypting archive.\n" ""
	gpg -v --decrypt $1 | tar xv -C $2

	local size_before=$(ls -lah $2/$label.tar.gpg | awk '{ print $5 }')
	local size_after=$(du -hs $1 | awk '{ print $1 }')
	printf "[%5s] Archive unpacked to %s (%s->%s).\n" "ok" "$2/$label.tar.gpg" $size_before $size_after
}

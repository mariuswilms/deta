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

msgok "Module %s loaded." "backup"

# @FUNCTION: archive
# @USAGE: [source dir] [target dir] [label prefix]
# @DESCRIPTION:
# Archives source directory by creating a labeled archive in target directory.
# Symlinks are *not* dereferenced when creating the archive.
archive() {
	local label=${3}-$(date +%Y-%m-%d-%H-%M)
	local tmp=$(mktemp -d -t deta)
	defer rm -rf $tmp

	msg "Creating and verifying archive from %s." $1
	cd $1
	tar -Wp -cf $tmp/$label.tar *
	cd -

	msg "Encrypting archive."
	read -p "Encrypt for: " user
	gpg -v -z 0 -r $user --encrypt $tmp/$label.tar

	msg "Verifying encrypted archive."
	gpg -v -ba -u $user $tmp/$label.tar.gpg
	gpg -v --verify $tmp/$label.tar.gpg.asc

	msg "Copying archive into target directory."
	cp -v $tmp/$label.tar.gpg $2/

	local size_before=$(du -hs $1 | awk '{ print $1 }')
	local size_after=$(ls -lah $2/$label.tar.gpg | awk '{ print $5 }')
	msgok "Archive created at %s (%s->%s)." "$2/$label.tar.gpg" $size_before $size_after
}

# @FUNCTION: dearchive
# @USAGE: [source file] [target dir]
# @DESCRIPTION:
# Decrypts and unpacks archive [source] to directory [target].
dearchive() {
	msg "Decrypting archive."
	gpg -v --decrypt $1 | tar xv -C $2

	local size_before=$(ls -lah $1 | awk '{ print $5 }')
	local size_after=$(du -hs $2 | awk '{ print $1 }')
	msgok "Archive unpacked to %s (%s->%s)." $2 $size_before $size_after
}

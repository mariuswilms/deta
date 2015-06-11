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

msginfo "Module %s loaded." "backup"

# @FUNCTION: archive
# @USAGE: <source dir> <target dir> <label prefix>
# @DESCRIPTION:
# Archives source directory by creating a labeled and encrypted archive in
# target directory. For symmetric encryption this function depends on gpg to be
# installed. Symlinks are *not* dereferenced when creating the archive.
archive() {
	local label=${3}-$(date +%Y-%m-%d-%H-%M)

	msg "Creating and encrypting archive from %s in target %s." $1 $2
	read -p "Encrypt for: " user
	cd $1
	tar -p -cf - * | gpg -v -z 0 -r $user --encrypt -o $2/$label.tar.gpg -
	cd -

	local size_before=$(du -hs $1 | awk '{ print $1 }')
	local size_after=$(ls -lah $2/$label.tar.gpg | awk '{ print $5 }')
	msgok "Archive created at %s (%s -> %s)." "$2/$label.tar.gpg" $size_before $size_after
}

# @FUNCTION: dearchive
# @USAGE: <source file> <target dir>
# @DESCRIPTION:
# Decrypts and unpacks archive <source> to directory <target>.
dearchive() {
	msg "Decrypting archive."
	gpg -v --decrypt $1 | tar xv -C $2

	local size_before=$(ls -lah $1 | awk '{ print $5 }')
	local size_after=$(du -hs $2 | awk '{ print $1 }')
	msgok "Archive unpacked to %s (%s -> %s)." $2 $size_before $size_after
}

# @FUNCTION: verifyarchive
# @USAGE: <path to file to verify>
# @DESCRIPTION:
# Verifies an encrypted archive.
verifyarchive() {
	local file=$1

	msg "Verifying encrypted archive."
	read -p "Encrypted for: " user

	gpg -v -ba -u $user $file
	gpg -v --verify ${file}.asc
	rm ${file}.asc
}

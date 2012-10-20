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

msgok "Module %s loaded." "media"

# @FUNCTION: compress_js
# @USAGE: [file]
# @DESCRIPTION:
# Compresses JavaScript file in-place.
function compress_js() {
	local before=$(ls -lah $1 | awk '{ print $5 }')

	$YUICOMPRESSOR -o $1 --nomunge --charset utf-8 $1

	local after=$(ls -lah $1 | awk '{ print $5 }')
	msgok "Compressed $1 ($before -> $after)"
}

# @FUNCTION: compress_css
# @USAGE: [file]
# @DESCRIPTION:
# Compresses CSS file in-place.
function compress_css() {
	local before=$(ls -lah $1 | awk '{ print $5 }')

	$YUICOMPRESSOR -o $1 --nomunge --charset utf-8 $1

	local after=$(ls -lah $1 | awk '{ print $5 }')
	msgok "Compressed $1 ($before -> $after)"
}

# @FUNCTION: compress_img
# @USAGE: [file]
# @DESCRIPTION:
# Compresses image file in-place.
function compress_img() {
	local before=$(ls -lah $1 | awk '{ print $5 }')

	pngcrush -rem alla -rem text -q $1 $1.tmp
	mv $1.tmp $1

	local after=$(ls -lah $1 | awk '{ print $5 }')
	msgok "Compressed $1 ($before -> $after)"
done

# @FUNCTION: bundle_js
# @USAGE: [target file] [files...]
# @DESCRIPTION:
# Compresses CSS file in-place.
function bundle_js() {
	local target=$1
	shift

	msg "Creating JavaScript bundle in $target."

	for file in $@; do
		msg "Including $file."
		cat $file >> $target
		echo ";"  >> $target
	done
}



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

# Which compressor to use when compressing JavaScript files. Currently
# "yuicompressor", "closure-compiler", "uglify-js" and "uglify-js2" are
# supported. For more information see the documentation for compress_js().
COMPRESSOR_JS=${COMPRESSOR_JS:-"yuicompressor"}

# Which compressor to use when compressing CSS files. Currently only
# "yuicompressor" is supported. For more information see the
# documentation for compress_css().
COMPRESSOR_CSS=${COMPRESSOR_CSS:-"yuicompressor"}

# @FUNCTION: compress_js
# @USAGE: [file]
# @DESCRIPTION:
# Compresses JavaScript file in-place.
function compress_js() {
	local before=$(ls -lah $1 | awk '{ print $5 }')

	case $COMPRESSOR_JS in
		yuicompressor)    yuicompressor -o $1 --nomunge --charset utf-8 $1;;
		uglify-js)        uglifyjs --overwrite $1;;
		uglify-js2)       uglifyjs2 $1 -c --comments -o $1;;
		closure-compiler) closure-compiler --js $1 --js_output_file $1;;
	esac

	local after=$(ls -lah $1 | awk '{ print $5 }')
	msgok "Compressed $1 ($before -> $after)"
}

# @FUNCTION: compress_css
# @USAGE: [file]
# @DESCRIPTION:
# Compresses CSS file in-place.
function compress_css() {
	local before=$(ls -lah $1 | awk '{ print $5 }')

	case $COMPRESSOR_CSS in
		yuicompressor)    yuicompressor -o $1 --charset utf-8 $1;;
	esac

	local after=$(ls -lah $1 | awk '{ print $5 }')
	msgok "Compressed $1 ($before -> $after)"
}

# @FUNCTION: compress_img
# @USAGE: [file]
# @DESCRIPTION:
# Compresses image file in-place.
function compress_img() {
	local before=$(ls -lah $1 | awk '{ print $5 }')

	case $1 in
		*.png)
			pngcrush -rem alla -rem text -q $1 $1.tmp
			mv $1.tmp $1
		;;
		*.jpg)
			mogrify -strip $1
			jpegtran -optimize -copy none $1 -outfile $1.tmp
			mv $1.tmp $1
		;;
	esac

	local after=$(ls -lah $1 | awk '{ print $5 }')
	msgok "Compressed $1 ($before -> $after)"
}

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



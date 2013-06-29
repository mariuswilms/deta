#
# deta
#
# Copyright (c) 2011-2013 David Persson
#
# Distributed under the terms of the MIT License.
# Redistributions of files must retain the above copyright notice.
#
# @COPYRIGHT 2011-2013 David Persson <nperson@gmx.de>
# @LICENSE   http://www.opensource.org/licenses/mit-license.php The MIT License
# @LINK      http://github.com/davidpersson/deta
#

msgok "Module %s loaded." "asset"

# Which compressor to use when compressing JavaScript files. Currently
# "yuicompressor", "closure-compiler" and "uglify-js" (>= 2.0) are
# supported. For more information see the documentation for compress_js().
COMPRESSOR_JS=${COMPRESSOR_JS:-"uglify-js"}

# Which compressor to use when compressing CSS files. Currently only
# "yuicompressor" is supported. For more information see the
# documentation for compress_css().
COMPRESSOR_CSS=${COMPRESSOR_CSS:-"yuicompressor"}

# @FUNCTION: compress_js
# @USAGE: <target file> <source file 1> [source file 2] [...]
# @DESCRIPTION:
# Compresses and bundles JavaScript files. Depending on the setting of
# COMPRESSOR_JS relies on certain tools to be available.
function compress_js() {
	local target=$1
	shift

	msg "Compressing %s to %s." "$@" $target

	case $COMPRESSOR_JS in
		yuicompressor)
			yuicompressor -o $target --nomunge --charset utf-8 $@
			;;
		uglify-js)
			uglifyjs $@ -c --comments -o $target \
				--source-map $target.map
			;;
		closure-compiler)
			closure-compiler --js $@ --js_output_file $target \
				--create_source_map $target.map
			;;
	esac
}

# @FUNCTION: compress_css
# @USAGE: <target file> <source file 1> [source file 2] [...]
# @DESCRIPTION:
# Compresses and bundles CSS files. Depending on the setting of
# COMPRESSOR_CSS relies on certain tools to be available.
function compress_css() {
	local target=$1
	shift

	msg "Compressing %s to %s." $1 $target

	case $COMPRESSOR_CSS in
		yuicompressor)    yuicompressor -o $target --charset utf-8 $@;;
	esac
}

# @FUNCTION: compress_img
# @USAGE: <image file>
# @DESCRIPTION:
# Compresses image file in-place. Relies on pngcrush, imagemagick
# and jpegtran to be available on the system.
function compress_img() {
	msg "Compressing %s to %s." $1 $1

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
}


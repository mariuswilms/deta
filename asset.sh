#
# deta
#
# Copyright (c) 2011-2014 David Persson
#
# Distributed under the terms of the MIT License.
# Redistributions of files must retain the above copyright notice.
#
# @COPYRIGHT 2011-2014 David Persson <nperson@gmx.de>
# @LICENSE   http://www.opensource.org/licenses/mit-license.php The MIT License
# @LINK      http://github.com/davidpersson/deta
#

msginfo "Module %s loaded." "asset"

# Which compressor to use when compressing JavaScript files. Currently
# "yuicompressor", "closure-compiler" and "uglify-js" (>= 2.0) are
# supported. For more information see the documentation for compress_js().
COMPRESSOR_JS=${COMPRESSOR_JS:-"uglify-js"}

# Which compressor to use when compressing CSS files. Currently
# "yuicompressor", "clean-css" and "sqwish" are supported. For more
# information see the documentation for compress_css().
COMPRESSOR_CSS=${COMPRESSOR_CSS:-"yuicompressor"}

# @FUNCTION: compress_js
# @USAGE: <target file> <source file 1> [source file 2] [...]
# @DESCRIPTION:
# Compresses and bundles JavaScript files. Depending on the setting of
# COMPRESSOR_JS relies on certain tools to be available.
function compress_js() {
	local target=$1
	local key="compress_js_${COMPRESSOR_JS}_$(md5 -q $@ | md5)"
	shift

	if [[ "$@" == $target ]]; then
		msg "Compressing %s in-place." $target
	else
		msg "Compressing and bundling %s to %s." "$@" $target
	fi

	if [[ $(_cache_exists $key) == "true" ]]; then
		_cache_read_into_file $key $target
		return 0
	fi

	case $COMPRESSOR_JS in
		yuicompressor)
			yuicompressor -o $target --nomunge --charset utf-8 $@
			;;
		uglify-js)
			uglifyjs $@ -c --comments -o $target \
				--stats \
				--source-map $target.map
			;;
		closure-compiler)
			closure-compiler --js $@ --js_output_file $target \
				--create_source_map $target.map
			;;
	esac

	_cache_write_from_file $key $target
}

# @FUNCTION: bundle_js
# @USAGE: <target file> [files...]
# @DESCRIPTION:
# Safely bundles multiple JavaScript files into one.
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

# @FUNCTION: compress_css
# @USAGE: <target file> <source file 1> [source file 2] [...]
# @DESCRIPTION:
# Compresses and bundles CSS files. Depending on the setting of
# COMPRESSOR_CSS relies on certain tools to be available.
function compress_css() {
	local target=$1
	local key="compress_css_${COMPRESSOR_CSS}_$(md5 -q $@ | md5)"
	shift

	if [[ "$@" == $target ]]; then
		msg "Compressing %s in-place." $target
	else
		msg "Compressing and bundling %s to %s." "$@" $target
	fi

	if [[ $(_cache_exists $key) == "true" ]]; then
		_cache_read_into_file $key $target
		return 0
	fi

	if [[ $COMPRESSOR_CSS == {sqwish,clean-css} ]]; then
		# Does not support bundling by itself.
		if [[ $# > 2 ]]; then
			tmp=$(mktemp -t deta)
			defer rm $tmp

			bundle_css $tmp $@
		else
			tmp=$target
		fi
	fi

	case $COMPRESSOR_CSS in
		yuicompressor)
			yuicompressor -o $target --charset utf-8 $@
			;;
		clean-css)
			clean-css --skip-import --skip-rebase -o $target $tmp
			;;
		sqwish)
			sqwish $tmp -o $target
			;;
	esac

	_cache_write_from_file $key $target
}

# @FUNCTION: bundle_css
# @USAGE: <target file> [files...]
# @DESCRIPTION:
# Bundles multiple CSS files into one.
# @FIXME Make safe for files containing @charset.
function bundle_css() {
	local target=$1
	shift

	msg "Creating CSS bundle in $target."

	for file in $@; do
		msg "Including $file."
		cat $file >> $target
	done
}

# @FUNCTION: compress_img
# @USAGE: <image file>
# @DESCRIPTION:
# Compresses image file in-place. Relies on pngcrush, imagemagick
# and jpegtran to be available on the system.
function compress_img() {
	local file=$1
	local key="compress_img_$(md5 -q $@ | md5)"

	msg "Compressing %s in-place." $file

	if [[ $(_cache_exists $key) == "true" ]]; then
		_cache_read_into_file $key $target
		return 0
	fi

	case $file in
		*.png)
			pngcrush -rem alla -rem text -q $file $file.tmp
			mv $file.tmp $file
		;;
		*.jpg)
			mogrify -strip $file
			jpegtran -optimize -copy none $file -outfile $file.tmp
			mv $file.tmp $file
		;;
	esac

	_cache_write_from_file $key $file
}


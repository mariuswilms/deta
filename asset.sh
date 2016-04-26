#
# deta
#
# Copyright (c) 2011 David Persson
#
# Distributed under the terms of the MIT License.
# Redistributions of files must retain the above copyright notice.
#

msginfo "Module %s loaded." "asset"

# Compressor to use when compressing JavaScript files. Currently
# "yuicompressor", "closure-compiler" and "uglify-js" (>= 2.0) are
# supported.
COMPRESSOR_JS=${COMPRESSOR_JS:-"closure-compiler"}

# Compressor to use when compressing CSS files. Currently
# "yuicompressor", "clean-css" and "sqwish" are supported.
COMPRESSOR_CSS=${COMPRESSOR_CSS:-"yuicompressor"}

# Compressor to use when compressing PNG files. Currently
# "pngcrush" and "pngquant" are supported.
COMPRESSOR_PNG=${COMPRESSOR_PNG:-"pngcrush"}

# Compressor to use when compressing JPG files. Currently
# "imagemagick" and "jpegtran" are supported.
COMPRESSOR_JPG=${COMPRESSOR_JPG:-"imagemagick jpegtran"}

# @FUNCTION: compress_js
# @USAGE: <target file> <source file 1> [source file 2] [...]
# @DESCRIPTION:
# Compresses and bundles JavaScript files. Depending on the setting
# of COMPRESSOR_JS relies on certain tools to be available.
function compress_js() {
	local target=$1
	local key="compress_js_$(_calc_md5 "${COMPRESSOR_JS}")_$(_calc_md5_file $@)"
	shift

	if [[ "$@" == $target ]]; then
		msg "Compressing %s in-place." $target
	else
		msg "Compressing %s to %s." "$@" $target
	fi

	if [[ $(_cache_exists $key) == "y" ]]; then
		_cache_read_into_file $key $target
		return 0
	fi
	# Always work over the tmp file which becomes the source.
	local tmp=$(mktemp -t deta.XXX).js
	defer rm $tmp

	if [[ $# > 2 ]]; then
		# Always bundle mutliple files into one first. Even
		# though some compressors support bundling themselves
		# we do it for generalized behavior here.

		# Args already shifted above, contain just the source files.
		bundle_js $tmp $@
	else
		cp $1 $tmp
	fi

	for compressor in $COMPRESSOR_JS; do
		case $compressor in
			yuicompressor)
				yuicompressor --type js -o $target --nomunge --charset utf-8 $tmp
				;;
			uglify-js)
				uglifyjs $tmp -c --comments -o $target
				;;
			closure-compiler)
				closure-compiler --js $tmp --js_output_file $target
				;;
		esac

		# Allow subsequent compressors pick up the updated file.
		cp $target $tmp
	done

	_cache_write_from_file $key $target
}

# @FUNCTION: bundle_js
# @USAGE: <target file> [files...]
# @DESCRIPTION:
# Safely bundles multiple JavaScript files into one.
function bundle_js() {
	local target=$1
	shift

	msg "Creating JavaScript bundle in %s." $target

	for file in $@; do
		msg "Including $file."
		cat $file >> $target
		echo ";"  >> $target
	done
}

# @FUNCTION: compress_css
# @USAGE: <target file> <source file 1> [source file 2] [...]
# @DESCRIPTION:
# Compresses and bundles CSS files. Generates source maps if a compressing tool supports
# Cit. Depending on the setting of COMPRESSOR_CSS relies on certain tools to be available.
function compress_css() {
	local target=$1
	local key="compress_css_$(_calc_md5 "${COMPRESSOR_CSS}")_$(_calc_md5_file $@)"
	shift

	if [[ "$@" == $target ]]; then
		msg "Compressing %s in-place." $target
	else
		msg "Compressing %s to %s." "$@" $target
	fi

	if [[ $(_cache_exists $key) == "y" ]]; then
		_cache_read_into_file $key $target
		return 0
	fi

	# Always work over the tmp file which becomes the source.
	local tmp=$(mktemp -t deta.XXX).css
	defer rm $tmp

	if [[ $# > 2 ]]; then
		# Always bundle mutliple files into one first. Even
		# though some compressors support bundling themselves
		# we do it for generalized behavior here.

		# Args already shifted above, contain just the source files.
		bundle_css $tmp $@
	else
		cp $1 $tmp
	fi

	for compressor in $COMPRESSOR_CSS; do
		case $compressor in
			yuicompressor)
				yuicompressor --type css -o $target --charset utf-8 $tmp
				;;
			clean-css)
				clean-css --skip-import --skip-rebase -o $target $tmp
				;;
			sqwish)
				sqwish $tmp -o $target
				;;
		esac

		# Allow subsequent compressors pick up the updated file.
		cp $target $tmp
	done

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

	msg "Creating CSS bundle in %s." $target

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
	local key="compress_img_$(_calc_md5 "${COMPRESSOR_PNG}${COMPRESSOR_JPG}")_$(_calc_md5_file $@)"

	msg "Compressing %s in-place." $file

	if [[ $(_cache_exists $key) == "y" ]]; then
		_cache_read_into_file $key $file
		return 0
	fi

	case $file in
		*.png)
			for compressor in $COMPRESSOR_PNG; do
				case $compressor in
					pngcrush)
						pngcrush -rem alla -rem text -q $file $file.tmp
						mv $file.tmp $file
					;;
					pngquant)
						pngquant --speed 1 $file -o $file.tmp
						mv $file.tmp $file
					;;
				esac
			done
		;;
		*.jpg)
			for compressor in $COMPRESSOR_JPG; do
				case $compressor in
					imagemagick)
						mogrify -strip $file
					;;
					jpegtran)
						jpegtran -optimize -copy none $file -outfile $file.tmp
						mv $file.tmp $file
					;;
				esac
			done
		;;
	esac

	_cache_write_from_file $key $file
}


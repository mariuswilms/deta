#
# deta
#
# Copyright (c) 2011 David Persson
#
# Distributed under the terms of the MIT License.
# Redistributions of files must retain the above copyright notice.
#

msginfo "Module %s loaded." "g11n"

# @FUNCTION: g11n_compile_mo
# @USAGE: <directory with PO files>
# @DESCRIPTION:
# Compiles all PO files in the given directory into MO format.
g11n_compile_mo() {
	msg "Compiling *.po in %s." $@
	for file in $(find $1 -type f -name *.po); do
		msgfmt -o ${file/.po/.mo} --verbose $file
	done
}

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

printf "[%5s] Module %s loaded.\n" "ok" "g11n"

# @FUNCTION: g11n_compile_mo
# @USAGE: [directory with PO files]
# @DESCRIPTION:
# Compiles all PO files in the given directory into MO format.
g11n_compile_mo {
	for FILE in $(find $1 -type f -name *.po); do
		msgfmt -o ${FILE/.po/.mo} --verbose $FILE
	done
}

# @FUNCTION: g11n_remove_mo
# @USAGE: [directory with MO files]
# @DESCRIPTION:
# Removes all compiled MO files in the given directory.
g11n_remove_mo {
	find $1 -type f -name *.mo | xargs rm -v
}


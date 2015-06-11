#
# deta
#
# Copyright (c) 2011 David Persson
#
# Distributed under the terms of the MIT License.
# Redistributions of files must retain the above copyright notice.
#

msginfo "Module %s loaded." "php"

# @FUNCTION: cakephp_configure
# @USAGE: <name> <new value> <config file>
# @DESCRIPTION:
# Modifies configure statements in i.e. app/core.php in place.
cakephp_configure() {
	msg "Setting %s to %s in %s." $@
	sed -i "" "s/'$1',.*)/'$1', $2)/g" $3
}

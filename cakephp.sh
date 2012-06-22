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

msgok "Module %s loaded." "cakephp"

# @FUNCTION: cakephp_configure
# @USAGE: [name] [new value] [config file]
# @DESCRIPTION:
# Modifies configure statements in i.e. app/core.php in place.
cakephp_configure() {
	msg "Setting %s to %s in %s." $@
	sed -i "" "s/'$1',.*)/'$1', $2)/g" $3
}

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

printf "[%5s] Module %s loaded.\n" "ok" "cakephp"

# @FUNCTION: cakephp_configure
# @USAGE: [name] [new value] [config file]
# @DESCRIPTION:
# Modifies configure statements in i.e. app/core.php in place.
cakephp_configure {
	sed -i "" "s/'$1',.*)/'$1', $2)/g" $3
}

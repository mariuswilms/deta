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

msginfo "Module %s loaded." "cache"

# @FUNCTION: cache_flush_memcached
# @USAGE: <memcached host> [memcached port]
# @DESCRIPTION:
# Flushes memcached cache entirely. The port if not given defaults to
# default assigned memcached port 11211.
cache_flush_memcached() {
	msg "Flushing memcached cache on %s:%d." $1

	set +o errexit
	(echo -e 'flush_all'; sleep 1) | telnet $1 ${2:-"11211"}
	set -o errexit
}

# @FUNCTION: cache_flush_phpstat
# @USAGE: <php>
# @DESCRIPTION:
# Flushes the local PHP stat cache.
cache_flush_phpstat() {
	msg "Clearing PHP stat cache."
	$1 -r "clearstatcache();"
}


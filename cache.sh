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

msgok "Module %s loaded." "cache"

# @FUNCTION: cache_flush_memcached
# @USAGE: <memcached host> [memcached port]
# @DESCRIPTION:
# Flushes memcached cache entirely. The port if not given defaults to
# default assigned memcached port 11211.
cache_flush_memcached() {
	host=$1
	port=${2:-11211}

	msg "Flushing memcached on %s:%d cache." $host $port

	set +o errexit
	(echo -e 'flush_all'; sleep 1) | telnet $host $port
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

# @FUNCTION: cache_flush_apc
# @USAGE: <php>
# @DESCRIPTION:
# Flushes the local APC system and user caches. Needs PHP
# command with APC extension to be available.
cache_flush_apc() {
	if [[ $($1 -m | grep -q apc) == 0 ]]; then
		msg "Clearing APC system and user cache."
		$1 -r "apc_clear(); apc_clear('user');"
	fi
}

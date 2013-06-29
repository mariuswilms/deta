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
# @DESCRIPTION:
# Flushes memcached cache entirely. The host and port are
# hardcoded to localhost:11211
cache_flush_memcached() {
	msg "Flushing memcached cache."

	set +o errexit
	(echo -e 'flush_all'; sleep 1) | telnet localhost 11211
	set -o errexit
}

# @FUNCTION: cache_flush_phpstat
# @DESCRIPTION:
# Flushes the PHP stat cache. Requires a 'THIS' environment.
cache_flush_phpstat() {
	msg "Clearing PHP stat cache."
	$THIS_PHP -r "clearstatcache();"
}

# @FUNCTION: cache_flush_apc
# @DESCRIPTION:
# Flushes the APC system and user caches. Needs PHP command with APC
# extension to be available. Requires a 'THIS' environment.
cache_flush_apc() {
	if [[ $($THIS_PHP -m | grep -q apc) == 0 ]]; then
		msg "Clearing APC system and user cache."
		$THIS_PHP -r "apc_clear(); apc_clear('user');"
	fi
}

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
# Flushed memcached cache entirely. The host and port are
# hardcoded to localhost:11211
cache_flush_memcached() {
	msg "Flushing memcached cache."

	set +o errexit
	(echo -e 'flush_all'; sleep 1) | telnet localhost 11211
	set -o errexit
}


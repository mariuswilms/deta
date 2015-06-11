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

msginfo "Module %s loaded." "security"

# @FUNCTION: integrity_spec_create
# @USAGE: <path> <target spec file> <ignore>
# @DESCRIPTION:
# Creates a mtree specification and shows sha256 sum for it.
integrity_spec_create() {
	msg "Creating mtree spec at %s." $2
	mtree -c -K cksum,md5digest \
		-p $1 \
		$(_mtree_ignore "$3") > $2

	msgok "SHA256: %s" $(shasum -p -a 256 $2 | awk '{print $1}')
}

# @FUNCTION: integrity_spec_check
# @USAGE: <path> <target spec file> <ignore>
# @DESCRIPTION:
# Checks a tree against mtree specifications..
integrity_spec_check() {
	if [[ -f $2 ]]; then
		msg "Checking against mtree spec %s." $2
		mtree -f $2 -p $1 $(_mtree_ignore "$3")

		if [[ $? == 0 ]]; then
			msgok "All good; integrity is consistent."
		else
			msgfail "Integrity check failed; not consistent!"
		fi
	else
		msgfail "No mtree spec at %s." $2
	fi
}

# @FUNCTION: _mtree_ignore
# @USAGE: <ignore>
# @DESCRIPTION:
# Takes a list of ignores and creates an argument to be passed to mtree.
_mtree_ignore() {
	local tmp=$(mktemp -t deta.XXX)

	for excluded in $1; do
		echo $excluded >> $tmp
	done
	echo "-X $tmp"
}

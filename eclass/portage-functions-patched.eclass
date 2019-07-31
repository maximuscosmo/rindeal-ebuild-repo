# Copyright 2016, 2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: portage-functions-patched.eclass
# @BLURB: Set of portage functions overrides

case "${EAPI:-0}" in
'6' | '7' ) ;;
* ) die "EAPI='${EAPI}' is not supported by '${ECLASS}' eclass" ;;
esac


## Origin: portage - bin/isolated-functions.sh
## PR: https://github.com/gentoo/portage/pull/26
rindeal:has() {
	local -- needle="${1}" ; shift
	local -- haystack=( "${@}" )

	local -- IFS=$'\a'

	## wrap every argument in IFS
	needle="${IFS}${needle}${IFS}"
	haystack=( "${haystack[@]/#/${IFS}}" )
	haystack=( "${haystack[@]/%/${IFS}}" )

	[[ "${haystack[*]}" == *"${needle}"* ]]
}
has() { rindeal:has "${@}" ; }

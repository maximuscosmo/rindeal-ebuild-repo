# Copyright 2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: git-utils.eclass
# @MAINTAINER:
# Jan Chren (rindeal) <dev.rindeal@gmail.com>

if ! (( _GIT_UTILS_ECLASS ))
then

case "${EAPI:-0}" in
7 ) ;;
* ) die "Unsupported EAPI='${EAPI}' for '${ECLASS}'" ;;
esac

inherit rindeal


git:snapshot:unpack() {
	(( $# != 2 )) && die
	local -r -- unpack_from="${1}"
	local -r -- unpack_to="${2}"

	printf ">>> Unpacking '%s' to '%s'\n" "${unpack_from##*/}" "${unpack_to}"
	mkdir -p "${unpack_to}" || die "Failed to create '${unpack_to}' directory"
	local -a tar=(
		tar --extract
		--strip-components=1
		--file="${unpack_from}" --directory="${unpack_to}"
	)
	debug-print "${tar[@]}"
	"${tar[@]}" || die "Failed to extract '${unpack_from}' archive"

	return 0
}


_GIT_UTILS_ECLASS=1
fi

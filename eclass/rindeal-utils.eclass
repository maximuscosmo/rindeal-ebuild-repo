# Copyright 2016, 2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: rindeal-utils.eclass
# @MAINTAINER:
# Jan Chren (rindeal) <dev.rindeal+gentoo-overlay@gmail.com>
# @BLURB: Collection of handy functions
# @DESCRIPTION:


if [[ -z "${_RINDEAL_UTILS_ECLASS}" ]]
then

case "${EAPI:-0}" in
6 | 7 ) ;;
* ) die "Unsupported EAPI='${EAPI}' for '${ECLASS}'" ;;
esac

inherit rindeal


rindeal:expand_vars() {
	local f_in="${1}"
	local f_out="${2}"
	(( $# > 2 || $# < 1 )) && die

	local sed_args=()
	local v vars=( $( grep -Eo '@[A-Z0-9_]+@' -- "${f_in}" | tr -d '@') )
	for v in "${vars[@]}"
	do
		if [[ -v "${v}" ]]
		then
			sed_args+=( -e "s|@${v}@|${!v}|g" )
		else
			einfo "${FUNCNAME}: var '${v}' doesn't exist"
		fi
	done

	local basedir="$(dirname "${WORKDIR}")"
	echo "Converting '${f_in#"${basedir}/"}' -> '${f_out#"${basedir}/"}"

	rsed "${sed_args[@]}" -- "${f_in}" >"${f_out}"
}

rindeal:prefix_flags() {
	(( $# < 2 )) && die

	local prefix="$1" ; shift
	local f flags=( "$@" )
	local regex="^([+-])?(.*)"

	for f in "${flags[@]}"
	do
		[[ "${f}" =~ ${regex} ]] || die
		printf "%s%s%s\n" "${BASH_REMATCH[1]}" "${prefix}" "${BASH_REMATCH[2]}"
	done
}


_RINDEAL_UTILS_ECLASS=1
fi

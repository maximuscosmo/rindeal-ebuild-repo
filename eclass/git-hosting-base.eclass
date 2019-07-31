# Copyright 2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: git-hosting-base.eclass
# @BLURB:

if ! (( _GIT_HOSTING_BASE_ECLASS ))
then

case "${EAPI:-0}" in
'7' ) ;;
* ) die "EAPI='${EAPI}' is not supported by '${ECLASS}' eclass" ;;
esac

inherit rindeal


## functions: str:tmpl:exp
inherit str-utils

## functions: archive:tar:unpack
inherit archive-utils


### BEGIN: Functions

git:hosting:gen_url() {
	local -- url_var=
	local -a args=( )

	while (( $# > 0 ))
	do
		case "${1}" in
		'--'* )
			if [[ $# -lt 2 || -z "${2}" || "${2}" == "--"* ]]
			then
				die "${1} value not provided"
			fi

			case "${1}" in
			'--url-var' )
				url_var="${2}"
				;;
			* )
				args+=( "${1}" "${2}" )
				;;
			esac

			shift 2
			;;
		* )
			die
			;;
		esac
	done

	[[ -z "${url_var}" ]] && die "--url-var argument is required, but wasn't specified"

	str:tmpl:exp --exp-tmpl-var "${url_var}" "${args[@]}"

	if [[ "${!url_var}" =~ '@'[A-Z_][A-Z0-9_]*'@' ]]
	then
		die "Error: Resulting string contains at least one unexpanded template variables: '${BASH_REMATCH[0]}'"
	fi

	return 0
}

git:hosting:sanitize_filename() {
	(( $# > 1 )) && die

	local -- filename="${1}"

	# replace all slashes with permitted characters
	filename="${filename//\//_-}" # TODO: come up with a better replacement

	## replace all not-permitted characters
	local regex='[^a-zA-Z0-9\.,+_-]'
	while [[ "${filename}" =~ ${regex} ]]
	do
		filename="${filename//${BASH_REMATCH[0]}/,}"
	done

	printf "%s" "${filename}"
}

git:hosting:unpack() {
	archive:tar:unpack --strip-components=1 -- "${@}"
}

### END: Functions


# prefer their CDN over Gentoo mirrors
RESTRICT+=" primaryuri"


_GIT_HOSTING_BASE_ECLASS=1
fi

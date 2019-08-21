# Copyright 2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: github.eclass
# @BLURB: Eclass for software hosted on public GitHub and GitHub clones (Gitea/Gogs) instances

if ! (( _GITHUB_ECLASS ))
then

case "${EAPI:-0}" in
7 ) ;;
* ) die "Unsupported EAPI='${EAPI}' for '${ECLASS}'" ;;
esac
inherit rindeal


### BEGIN: Inherits

# functions: git:hosting:gen_url, git:hosting:unpack, git:hosting:sanitize_filename
inherit git-hosting-base

## functions: str:tmpl:exp
inherit str-utils

### END: Inherits


### BEGIN: Functions

github:homepage:gen_url() {
	git:hosting:gen_url \
		--tmpl '${SVR}/${NS}/${PROJ}' \
		SVR="${GITHUB_SVR}" \
		NS="${GITHUB_NS}" \
		PROJ="${GITHUB_PROJ}" \
		"${@}"
}

github:snap:gen_url() {
	git:hosting:gen_url \
		--tmpl '${SVR}/${NS}/${PROJ}/archive/${REF}${EXT}' \
		SVR="${GITHUB_SVR}" \
		NS="${GITHUB_NS}" \
		PROJ="${GITHUB_PROJ}" \
		REF="${GITHUB_REF}" \
		EXT="${GITHUB_SNAP_EXT}" \
		"${@}"
}

github:snap:gen_src_uri() {
	local -- url_var= distfile_var=
	local -a args=( )

	while (( $# > 0 ))
	do
		case "${1}" in
		'--url-var' | '--distfile-var' )
			if [[ $# -lt 2 || -z "${2}" || "${2}" == "--"* ]]
			then
				die "${1} value not provided"
			fi

			case "${1}" in
			'--url-var' ) url_var="${2}" ;;
			'--distfile-var' ) distfile_var="${2}" ;;
			esac

			shift
			;;
		* )
			args+=( "${1}" )
			;;
		esac

		shift
	done
	[[ -z "${url_var}" || -z "${distfile_var}" ]] && die

	github:snap:gen_url --url-var "${url_var}" "${args[@]}"

	local -- distfile=

	str:tmpl:exp \
		--tmpl '${SVR}--${NS}/${PROJ}--${REF}${EXT}' \
		SVR="${GITHUB_SVR}" \
		NS="${GITHUB_NS}" \
		PROJ="${GITHUB_PROJ}" \
		REF="${GITHUB_REF}" \
		EXT="${GITHUB_SNAP_EXT}" \
		"${args[@]}" \
		--exp-tmpl-var distfile

	# strip URL before host part
	distfile="${distfile##*'://'}"
	# sanitize
	distfile="$(git:hosting:sanitize_filename "${distfile}")"

	local -n distfile_var_ref="${distfile_var}"
	distfile_var_ref="${distfile}"
}

github:git:gen_url() {
	git:hosting:gen_url \
		--tmpl '${SVR}/${NS}/${PROJ}.git' \
		SVR="${GITHUB_SVR}" \
		NS="${GITHUB_NS}" \
		PROJ="${GITHUB_PROJ}" \
		"${@}"
}

github:snap:unpack() {
	git:hosting:unpack "${@}"
}

github:src_unpack() {
	github:snap:unpack "${DISTDIR}/${GITHUB_SNAP_DISTFILE}" "${WORKDIR}/${P}"
}

### END: Functions


### BEGIN: Variables

##
# @ECLASS-VARIABLE: GITHUB_SVR
# @DESCRIPTION:
#   Set this to override default server URL.
#   No trailing slash!
# @DEFAULT:
#   "https://github.com"
##
declare -g -r -- GITHUB_SVR="${GITHUB_SVR:-"https://github.com"}"
[[ "${GITHUB_SVR:(-1)}" == '/' ]] && die "GITHUB_SVR ends with a slash"

##
# @ECLASS-VARIABLE: GITHUB_NS
# @DESCRIPTION:
#   Set this to override default namespace.
##
declare -g -r -- GITHUB_NS="${GITHUB_NS:-"${PN}"}"

##
# @ECLASS-VARIABLE: GITHUB_PROJ
# @DESCRIPTION:
#   Set this to override default project name.
##
declare -g -r -- GITHUB_PROJ="${GITHUB_PROJ:-"${PN}"}"

##
# @ECLASS-VARIABLE: GITHUB_REF
# @DESCRIPTION:
#   Set this to override default ref.
##
declare -g -r -- GITHUB_REF="${GITHUB_REF:-"${PV}"}"

##
# @ECLASS-VARIABLE: GITHUB_SNAP_EXT
##
declare -g -r -- GITHUB_SNAP_EXT="${GITHUB_SNAP_EXT:-".tar.gz"}"

##
# @ECLASS-VARIABLE: GITHUB_SNAP_URL
# @READONLY
##
##
# @ECLASS-VARIABLE: GITHUB_SNAP_DISTFILE
# @READONLY
##
declare -g -- GITHUB_SNAP_URL= GITHUB_SNAP_DISTFILE=
github:snap:gen_src_uri --url-var GITHUB_SNAP_URL --distfile-var GITHUB_SNAP_DISTFILE
readonly GITHUB_SNAP_URL GITHUB_SNAP_DISTFILE

##
# @ECLASS-VARIABLE: GITHUB_SRC_URI
# @READONLY
##
declare -g -r -- GITHUB_SRC_URI="${GITHUB_SNAP_URL} -> ${GITHUB_SNAP_DISTFILE}"

##
# @ECLASS-VARIABLE: GITHUB_HOMEPAGE
# @READONLY
##
declare -g -- GITHUB_HOMEPAGE=
github:homepage:gen_url --url-var GITHUB_HOMEPAGE
readonly GITHUB_HOMEPAGE

### END: Variables


_GITHUB_ECLASS=1
fi

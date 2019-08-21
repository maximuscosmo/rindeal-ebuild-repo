# Copyright 2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: cgit.eclass
# @BLURB: Eclass for software hosted on public cgit instances

if ! (( _CGIT_ECLASS ))
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

cgit:homepage:gen_url() {
	git:hosting:gen_url \
		--tmpl '${SVR}/${NS:+${NS}/}${PROJ}${DOT_GIT:+.git}/' \
		SVR="${CGIT_SVR}" \
		NS="${CGIT_NS}" \
		PROJ="${CGIT_PROJ}" \
		DOT_GIT="${CGIT_DOT_GIT}" \
		"${@}"
}

cgit:snap:gen_url() {
	git:hosting:gen_url \
		--tmpl '${SVR}/${NS:+${NS}/}${PROJ}${DOT_GIT:+.git}/snapshot/${PROJ}-${REF}${EXT}' \
		SVR="${CGIT_SVR}" \
		NS="${CGIT_NS}" \
		PROJ="${CGIT_PROJ}" \
		DOT_GIT="${CGIT_DOT_GIT}" \
		REF="${CGIT_REF}" \
		EXT="${CGIT_SNAP_EXT}" \
		"${@}"
}

cgit:snap:gen_src_uri() {
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

	cgit:snap:gen_url --url-var "${url_var}" "${args[@]}"

	local -- distfile=

	str:tmpl:exp \
		--tmpl '${SVR}--${NS:+${NS}/}${PROJ}--${REF}${EXT}' \
		SVR="${CGIT_SVR}" \
		NS="${CGIT_NS}" \
		PROJ="${CGIT_PROJ}" \
		REF="${CGIT_REF}" \
		EXT="${CGIT_SNAP_EXT}" \
		"${args[@]}" \
		--exp-tmpl-var distfile

	# strip URL before host part
	distfile="${distfile##*'://'}"
	# sanitize
	distfile="$(git:hosting:sanitize_filename "${distfile}")"

	local -n distfile_var_ref="${distfile_var}"
	distfile_var_ref="${distfile}"
}

cgit:git:gen_url() {
	cgit:homepage:gen_url "${@}"
}

cgit:snap:unpack() {
	git:hosting:unpack "${@}"
}

cgit:src_unpack() {
	cgit:snap:unpack "${DISTDIR}/${CGIT_SNAP_DISTFILE}" "${WORKDIR}/${P}"
}

### END: Functions


### BEGIN: Variables

##
# @ECLASS-VARIABLE: CGIT_SVR
# @DESCRIPTION:
#   Set this to override default server URL.
#   No trailing slash!
# @DEFAULT:
#   "https://git.zx2c4.com"
##
declare -g -r -- CGIT_SVR="${CGIT_SVR:-"https://git.zx2c4.com"}"
[[ "${CGIT_SVR:(-1)}" == '/' ]] && die "CGIT_SVR ends with a slash"

##
# @ECLASS-VARIABLE: CGIT_NS
# @DESCRIPTION:
#   Set this to override default namespace.
##
declare -g -r -- CGIT_NS="${CGIT_NS:-""}"

##
# @ECLASS-VARIABLE: CGIT_PROJ
# @DESCRIPTION:
#   Set this to override default project name.
##
declare -g -r -- CGIT_PROJ="${CGIT_PROJ:-"${PN}"}"

##
# @ECLASS-VARIABLE: CGIT_DOT_GIT
##
declare -g -r -- CGIT_DOT_GIT="${CGIT_DOT_GIT}"

##
# @ECLASS-VARIABLE: CGIT_REF
# @DESCRIPTION:
#   Set this to override default ref.
##
declare -g -r -- CGIT_REF="${CGIT_REF:-"${PV}"}"

##
# @ECLASS-VARIABLE: CGIT_SNAP_EXT
##
declare -g -r -- CGIT_SNAP_EXT="${CGIT_SNAP_EXT:-".tar.gz"}"

##
# @ECLASS-VARIABLE: CGIT_SNAP_URL
# @READONLY
##
##
# @ECLASS-VARIABLE: CGIT_SNAP_DISTFILE
# @READONLY
##
declare -g -- CGIT_SNAP_URL= CGIT_SNAP_DISTFILE=
cgit:snap:gen_src_uri --url-var CGIT_SNAP_URL --distfile-var CGIT_SNAP_DISTFILE
readonly CGIT_SNAP_URL CGIT_SNAP_DISTFILE

##
# @ECLASS-VARIABLE: CGIT_SRC_URI
# @READONLY
##
declare -g -r -- CGIT_SRC_URI="${CGIT_SNAP_URL} -> ${CGIT_SNAP_DISTFILE}"

##
# @ECLASS-VARIABLE: CGIT_HOMEPAGE
# @READONLY
##
declare -g -- CGIT_HOMEPAGE=
cgit:homepage:gen_url --url-var CGIT_HOMEPAGE
readonly CGIT_HOMEPAGE

### END: Variables


_CGIT_ECLASS=1
fi

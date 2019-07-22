# Copyright 2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: gitlab.eclass
# @BLURB: Eclass for software hosted on public GitLab instances

if ! (( _GITLAB_ECLASS ))
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

gitlab:homepage:gen_url() {
	git:hosting:gen_url \
		--tmpl "@SVR@/@NS@/@PROJ@" \
		--svr  "${GITLAB_SVR}" \
		--ns   "${GITLAB_NS}" \
		--proj "${GITLAB_PROJ}" \
		"${@}"
}

gitlab:snap:gen_url() {
	git:hosting:gen_url \
		--tmpl "@SVR@/@NS@/@PROJ@/-/archive/@REF@/@PROJ@-@REF@@EXT@" \
		--svr  "${GITLAB_SVR}" \
		--ns   "${GITLAB_NS}" \
		--proj "${GITLAB_PROJ}" \
		--ref  "${GITLAB_REF}" \
		--ext  "${GITLAB_SNAP_EXT}" \
		"${@}"
}

gitlab:snap:gen_src_uri() {
	local -- distfile_var=
	local -a args=( )

	while (( $# > 0 ))
	do
		(( $# < 2 )) && die

		case "${1}" in
		'--distfile-var' )
			if [[ -z "${2}" || "${2}" == "--"* ]]
			then
				die "--distfile-var value not provided"
			fi

			distfile_var="${2}"
			;;
		* )
			args+=( "${1}" "${2}" )
			;;
		esac

		shift 2
	done
	[[ -z "${distfile_var}" ]] && die

	gitlab:snap:gen_url "${args[@]}"

	local -- distfile=

	str:tmpl:exp \
		--tmpl "@SVR@--@NS@/@PROJ@--@REF@@EXT@" \
		--svr  "${GITLAB_SVR}" \
		--ns   "${GITLAB_NS}" \
		--proj "${GITLAB_PROJ}" \
		--ref  "${GITLAB_REF}" \
		--ext  "${GITLAB_SNAP_EXT}" \
		"${args[@]}" \
		--exp-tmpl-var distfile

	# strip URL before host part
	distfile="${distfile##*'://'}"
	# sanitize
	distfile="$(git:hosting:sanitize_filename "${distfile}")"

	local -n distfile_var_ref="${distfile_var}"
	distfile_var_ref="${distfile}"
}

gitlab:git:gen_url() {
	git:hosting:gen_url \
		--tmpl "@SVR@/@NS@/@PROJ@.git" \
		--svr  "${GITLAB_SVR}" \
		--ns   "${GITLAB_NS}" \
		--proj "${GITLAB_PROJ}" \
		"${@}"
}

gitlab:snap:unpack() {
	git:hosting:unpack "${@}"
}

gitlab:src_unpack() {
	gitlab:snap:unpack "${DISTDIR}/${GITLAB_SNAP_DISTFILE}" "${WORKDIR}/${P}"
}

### END: Functions


### BEGIN: Variables

##
# @ECLASS-VARIABLE: GITLAB_SVR
# @DESCRIPTION:
#   Set this to override default server URL.
#   No trailing slash!
# @DEFAULT:
#   "https://gitlab.com"
##
declare -g -r -- GITLAB_SVR="${GITLAB_SVR:-"https://gitlab.com"}"
[[ "${GITLAB_SVR:(-1)}" == '/' ]] && die "GITLAB_SVR ends with a slash"

##
# @ECLASS-VARIABLE: GITLAB_NS
# @DESCRIPTION:
#   Set this to override default namespace.
# @SEE
#   https://docs.gitlab.com/ee/api/README.html#namespaced-path-encoding
##
declare -g -r -- GITLAB_NS="${GITLAB_NS:-"${PN}"}"

##
# @ECLASS-VARIABLE: GITLAB_PROJ
# @DESCRIPTION:
#   Set this to override default project name.
# @SEE
#   https://docs.gitlab.com/ee/api/README.html#namespaced-path-encoding
##
declare -g -r -- GITLAB_PROJ="${GITLAB_PROJ:-"${PN}"}"

##
# @ECLASS-VARIABLE: GITLAB_REF
# @DESCRIPTION:
#   Set this to override default ref.
##
declare -g -r -- GITLAB_REF="${GITLAB_REF:-"${PV}"}"

##
# @ECLASS-VARIABLE: GITLAB_SNAP_EXT
##
declare -g -r -- GITLAB_SNAP_EXT="${GITLAB_SNAP_EXT:-".tar.bz2"}"

##
# @ECLASS-VARIABLE: GITLAB_SNAP_URL
# @READONLY
##
##
# @ECLASS-VARIABLE: GITLAB_SNAP_DISTFILE
# @READONLY
##
declare -g -- GITLAB_SNAP_URL= GITLAB_SNAP_DISTFILE=
gitlab:snap:gen_src_uri --url-var GITLAB_SNAP_URL --distfile-var GITLAB_SNAP_DISTFILE
readonly GITLAB_SNAP_URL GITLAB_SNAP_DISTFILE

##
# @ECLASS-VARIABLE: GITLAB_SRC_URI
# @READONLY
##
declare -g -r -- GITLAB_SRC_URI="${GITLAB_SNAP_URL} -> ${GITLAB_SNAP_DISTFILE}"

##
# @ECLASS-VARIABLE: GITLAB_HOMEPAGE
# @READONLY
##
declare -g -- GITLAB_HOMEPAGE=
gitlab:homepage:gen_url --url-var GITLAB_HOMEPAGE
readonly GITLAB_HOMEPAGE

### END: Variables


_GITLAB_ECLASS=1
fi

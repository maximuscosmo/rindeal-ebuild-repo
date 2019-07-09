# Copyright 2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: gitlab.eclass
# @MAINTAINER:
# Jan Chren (rindeal) <dev.rindeal@gmail.com>

if ! (( _GITLAB_ECLASS ))
then

case "${EAPI:-0}" in
7 ) ;;
* ) die "Unsupported EAPI='${EAPI}' for '${ECLASS}'" ;;
esac

inherit rindeal

## functions: rindeal:filter_A
inherit rindeal-utils

## functions: git:snapshot:unpack
inherit git-utils


### BEGIN: Base classes
### END: Base classes


### BEGIN: Functions

gitlab:homepage:gen_uri() {
	local -- _server_url="${_GITLAB_SERVER_URL}" _repo="${_GITLAB_REPO}"
	local -i _homepage_var_set=0

	while (( $# > 0 ))
	do
		_key="${1}"
		case "${_key}" in
		--server-url )
			(( $# < 2 )) && die
			_server_url="${2}"
			shift
			;;
		--repo )
			(( $# < 2 )) && die
			_repo="${2}"
			shift
			;;
		--homepage-var )
			(( $# < 2 )) && die
			local -n _homepage_var="${2}"
			local _homepage_var_set=1
			shift
			;;
		esac
		shift
	done

	if ! (( _homepage_var_set ))
	then
		die
	fi

	_homepage_var="${_server_url}/${_repo}"

	return 0
}

gitlab:snapshot:gen_uri() {
	local -- _server_url="${_GITLAB_SERVER_URL}" _repo="${_GITLAB_REPO}" _ref="${_GITLAB_REF}"
	local -i _uri_var_set=0 _distfile_var_set=0

	while (( $# > 0 ))
	do
		_key="${1}"
		case "${_key}" in
		--server-url )
			(( $# < 2 )) && die
			_server_url="${2}"
			shift
			;;
		--repo )
			(( $# < 2 )) && die
			_repo="${2}"
			shift
			;;
		--ref )
			(( $# < 2 )) && die
			_ref="${2}"
			shift
			;;

		--uri-var )
			(( $# < 2 )) && die
			local -n _uri_var="${2}"
			local _uri_var_set=1
			shift
			;;
		--distfile-var )
			(( $# < 2 )) && die
			local -n _distfile_var="${2}"
			local _distfile_var_set=1
			shift
			;;
		esac
		shift
	done
	! (( _uri_var_set )) && die

	local -r -- _ext=".tar.bz2"

	_uri_var="${_server_url}/${_repo}/-/archive/${_ref}/${_repo##*/}-${_ref}${_ext}"

	if (( _distfile_var_set ))
	then
		local _sanitized_server_url="${_server_url}"
		_sanitized_server_url="${_sanitized_server_url##*"://"}"
		_sanitized_server_url="${_sanitized_server_url//"."/_}"
		_sanitized_server_url="${_sanitized_server_url//"/"/__}"
		_distfile_var="${_sanitized_server_url}--${_repo//"/"/--}--${_ref//"/"/_}${_ext}"
	fi

	return 0
}

### END: Functions


### BEGIN: Variables

##
# @ECLASS-VARIABLE: GITLAB_SERVER_URL
# @DESCRIPTION:
# Set this to override default server url.
# No trailing slash!
##

##
# @ECLASS-VARIABLE: _GITLAB_SERVER_URL
# @PRIVATE
# @READONLY
# @DESCRIPTION:
##
declare -g -r -- _GITLAB_SERVER_URL="${GITLAB_SERVER_URL:-"https://gitlab.com"}"

##
# @ECLASS-VARIABLE: GITLAB_REPO
# @DESCRIPTION:
# Set this to override default repo
##

##
# @ECLASS-VARIABLE: _GITLAB_REPO
# @PRIVATE
# @READONLY
# @DESCRIPTION:
##
declare -g -r -- _GITLAB_REPO="${GITLAB_REPO:-"${PN}/${PN}"}"

##
# @ECLASS-VARIABLE: GITLAB_REF
# @DESCRIPTION:
# Set this to override default ref
##

##
# @ECLASS-VARIABLE: _GITLAB_REF
# @PRIVATE
# @READONLY
# @DESCRIPTION:
##
declare -g -r -- _GITLAB_REF="${GITLAB_REF:-"${PV}"}"

##
# @ECLASS-VARIABLE: GITLAB_HOMEPAGE
# @READONLY
##
declare -g -- GITLAB_HOMEPAGE=
gitlab:homepage:gen_uri --homepage-var GITLAB_HOMEPAGE
readonly GITLAB_HOMEPAGE

##
# @ECLASS-VARIABLE: GITLAB_SRC_URI
# @READONLY
##
##
# @ECLASS-VARIABLE: GITLAB_DISTFILE
# @READONLY
##
_gitlab_uri= GITLAB_DISTFILE=
gitlab:snapshot:gen_uri --uri-var _gitlab_uri --distfile-var GITLAB_DISTFILE
readonly GITLAB_DISTFILE
declare -g -r -- GITLAB_SRC_URI="${_gitlab_uri} -> ${GITLAB_DISTFILE}"
unset _gitlab_uri


### END: Variables


### BEGIN Exported functions

EXPORT_FUNCTIONS src_unpack

##
# @FUNCTION: git-hosting_src_unpack
# @DESCRIPTION:
##
gitlab_src_unpack() {
	debug-print-function "${FUNCNAME}"

	git:snapshot:unpack "${DISTDIR}/${GITLAB_DISTFILE}" "${WORKDIR}/${P}"
}

### END Exported functions


_GITLAB_ECLASS=1
fi

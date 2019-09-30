# SPDX-FileCopyrightText: 2019  Jan Chren (rindeal)  <dev.rindeal@gmail.com>
#
# SPDX-License-Identifier: GPL-2.0-only

##!
# @ECLASS: bitbucket.eclass
# @BLURB: Eclass for packages with source code hosted on public Bitbucket instances
##!

if ! (( _BITBUCKET_ECLASS ))
then

case "${EAPI:-"0"}" in
"7" ) ;;
* ) die "EAPI='${EAPI}' is not supported by ECLASS='${ECLASS}'" ;;
esac

inherit rindeal


### BEGIN: Inherits

# functions: git:hosting:base:*
inherit git-hosting-base

### END: Inherits

### BEGIN: Functions

git:hosting:base:gen_fns "bitbucket"

### END: Functions

### BEGIN: Constants

declare -g -r -A _BITBUCKET_TMPL_VARS=(
	["SVR"]=BITBUCKET_SVR
	["NS"]=BITBUCKET_NS
	["PROJ"]=BITBUCKET_PROJ
	["REF"]=BITBUCKET_REF
	["EXT"]=BITBUCKET_SNAP_EXT
)

declare -g -r -A _BITBUCKET_TMPLS=(
	["base"]='${SVR}/${NS}/${PROJ}'
	["homepage:gen_url"]="${_BITBUCKET_TMPLS["base"]}"
	["git:gen_url"]="${_BITBUCKET_TMPLS["base"]}.git"
	["snap:gen_url"]="${_BITBUCKET_TMPLS["base"]}"'/get/${REF}${EXT}'
	["snap:gen_distfile"]='${SVR}--${NS}/${PROJ}--${REF}${EXT}'
)

### END: Constants

### BEGIN: Variables

declare -g -r -- BITBUCKET_SVR="${BITBUCKET_SVR:-"https://bitbucket.org"}"
[[ "${BITBUCKET_SVR:(-1)}" == '/' ]] && die "BITBUCKET_SVR ends with a slash"

declare -g -r -- BITBUCKET_NS="${BITBUCKET_NS:-"${PN}"}"

declare -g -r -- BITBUCKET_PROJ="${BITBUCKET_PROJ:-"${PN}"}"

declare -g -r -- BITBUCKET_REF="${BITBUCKET_REF:-"${PV}"}"

declare -g -r -- BITBUCKET_SNAP_EXT="${BITBUCKET_SNAP_EXT:-".tar.bz2"}"

## BEGIN: Readonly variables

git:hosting:base:gen_vars "bitbucket"

## END: Readonly variables

### END: Variables


_BITBUCKET_ECLASS=1
fi

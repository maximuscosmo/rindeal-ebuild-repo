# Copyright 2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2
# Based in part upon 'bash-completion-r1.eclass', which is:
#     Copyright 1999-2018 Gentoo Foundation

# @ECLASS: bash-completion.eclass
# @BLURB: bash-completion


if ! (( _BASH_COMPLETION_ECLASS ))
then

case "${EAPI:-0}" in
'6' | '7' ) ;;
* ) die "EAPI='${EAPI}' is not supported by '${ECLASS}' eclass" ;;
esac
inherit rindeal


## functions: tc-getPKG_CONFIG
inherit toolchain-funcs


bash:completion:_strip_eprefix() {
	(( ${#} != 1 )) && die

	printf -- "%s" "${1#${EPREFIX}}"
}

bash:completion:_pkgconfig_get_var() {
	debug-print-function "${FUNCNAME[0]}" "${@}"

	(( ${#} != 2 )) && die

	local -r -- varname="${1}" default="${2}"
	local -- cache_varname
	cache_varname="_BASH_COMPLETION_${varname^^}"
	cache_varname="${cache_varname//-/_}"
	readonly cache_varname

	if [[ -v "${cache_varname}" ]]
	then
		printf "%s" "${!cache_varname}"
	fi

	local -- value="${default}"

	if "$(tc-getPKG_CONFIG)" --exists bash-completion &>/dev/null
	then
		value="$("$(tc-getPKG_CONFIG)" --variable="${1}" bash-completion || die )"
	fi

	declare -g -r -- "${cache_varname}=${value}"

	printf "%s" "${value}"
}

# @FUNCTION: bash:completion:get_compdir
# @DESCRIPTION:
# Get the bash-completion completions directory.
bash:completion:get_completionsdir() {
	(( ${#} )) && die

	bash:completion:_pkgconfig_get_var "completionsdir" "/usr/share/bash-completion/completions"
}

# @FUNCTION: bash:completion:get_helpersdir
# @INTERNAL
# @DESCRIPTION:
# Get the bash-completion helpers directory.
bash:completion:get_helpersdir() {
	(( ${#} )) && die

	bash:completion:_pkgconfig_get_var "helpersdir"     "/usr/share/bash-completion/helpers"
}

bash:completion:_insproxy() {
	debug-print-function "${FUNCNAME[0]}" "${@}"

	(( ${#} < 1 )) && die

	local -r -- helper="${1}"
	shift

	(
		insinto "$(bash:completion:_strip_eprefix "$(bash:completion:get_completionsdir)")"
		insopts -m 0644
		"${helper}" "${@}"
	)
}

# @FUNCTION: dobashcomp
# @USAGE: like `doins`
# @DESCRIPTION:
# Install bash-completion files passed as args.
dobashcomp() {
	bash:completion:_insproxy doins "${@}"
}

# @FUNCTION: newbashcomp
# @USAGE: like `newins`
# @DESCRIPTION:
# Install bash-completion file under a new name.
newbashcomp() {
	bash:completion:_insproxy newins "${@}"
}

# @FUNCTION: aliasbashcomp
# @USAGE: <basename> <alias>...
# @DESCRIPTION:
# Alias <basename> completion to one or more commands (<alias>es).
aliasbashcomp() {
	debug-print-function "${FUNCNAME[0]}" "${@}"

	(( ${#} < 2 )) && die

	local -r -- base="${1}"
	shift

	[[ "${base}" == *"/"* ]] && die

	local -- completionsdir
	completionsdir="$(bash:completion:_strip_eprefix "$(bash:completion:get_completionsdir)")"
	readonly completionsdir

	rdosym -- "${base}" "${@/#/${completionsdir}/}"
}


_BASH_COMPLETION_ECLASS=1
fi

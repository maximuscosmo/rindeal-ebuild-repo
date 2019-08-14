# Copyright 2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: str-utils.eclass
# @BLURB:

if ! (( _STR_UTILS_ECLASS ))
then

case "${EAPI:-0}" in
'7' ) ;;
* ) die "EAPI='${EAPI}' is not supported by '${ECLASS}' eclass" ;;
esac

inherit rindeal


### BEGIN: Functions

str:tmpl:exp() {
	local -- _tmpl= _exp_tmpl_var=
	local -A _vars=( )

	while (( $# > 0 ))
	do
		if [[ "${1}" == '--'* ]] && [[ $# -lt 2 || "${2}" == '--'[[:alpha:]]* ]]
		then
			die "Argument '${1}' requires a value, but it wasnt provided"
		fi

		case "${1}" in
		'--tmpl' )
			_tmpl="${2}"
			shift
			;;
		'--exp-tmpl-var' )
			_exp_tmpl_var="${2}"
			shift
			;;
		[A-Z_][A-Z0-9_]*=* )
			if ! [[ "${1}" =~ ^[A-Z_][A-Z0-9_]*=.*$ ]]
			then
				die "Invalid argument: '${1}'"
			fi

			local -- _key="${1%%=*}" _val="${1#*=}"

			_vars["${_key}"]="${_val}"
			;;
		* )
			die "Unknown argument: '${1}'"
			;;
		esac

		shift
	done

	[[ -z "${_tmpl}" || -z "${_exp_tmpl_var}" ]] && die

	local -- _key
	for _key in "${!_vars[@]}"
	do
		local _val="${_vars["${_key}"]}"

		local -r -- "${_key}=${_val}"
	done

	local -n _exp_tmpl_var_ref="${_exp_tmpl_var}"

	eval _exp_tmpl_var_ref="${_tmpl}"
}

### END: Functions


_STR_UTILS_ECLASS=1
fi

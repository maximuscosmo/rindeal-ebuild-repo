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
		if [[ $# -lt 2 || "${2}" == '--'[[:alpha:]]* ]]
		then
			die "Argument '${1}' requires a value, but it wasnt provided"
		fi

		case "${1}" in
		'--tmpl' )
			_tmpl="${2}"
			;;
		'--exp-tmpl-var' )
			_exp_tmpl_var="${2}"
			;;
		'--'[[:alpha:]]* )
			local _key="${1}" _val="${2}"
			_key="${_key#--}"
			_vars["${_key}"]="${_val}"
			;;
		* )
			die
			;;
		esac

		shift 2
	done

	[[ -z "${_tmpl}" || -z "${_exp_tmpl_var}" ]] && die

	local _exp_tmpl="${_tmpl}"

	local _key
	for _key in "${!_vars[@]}"
	do
		local -- _val= _varname=

		_val="${_vars["${_key}"]}"

		_varname="${_key}"
		_varname="${_varname^^}"
		_varname="${_varname//-/_}"

		_exp_tmpl="${_exp_tmpl//@${_varname}@/${_val}}"
	done

	local -n _exp_tmpl_var_ref="${_exp_tmpl_var}"
	_exp_tmpl_var_ref="${_exp_tmpl}"
}

### END: Functions


_STR_UTILS_ECLASS=1
fi

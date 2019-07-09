# Copyright 2016, 2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: portage-patches.eclass
# @MAINTAINER:
# Jan Chren (rindeal) <dev.rindeal@gmail.com>
# @BLURB: Set of portage functions overrides intended to be used anywhere
# @DESCRIPTION:

case "${EAPI:-0}" in
6 | 7 ) ;;
* ) die "Unsupported EAPI='${EAPI}' for '${ECLASS}'" ;;
esac


## Origin: portage - bin/isolated-functions.sh
## PR: https://github.com/gentoo/portage/pull/26
rindeal:has() {
	local needle="${1}" ; shift
	local haystack=( "$@" )

	local IFS=$'\a'

	## wrap every argument in IFS
	needle="${IFS}${needle}${IFS}"
	haystack=( "${haystack[@]/#/${IFS}}" )
	haystack=( "${haystack[@]/%/${IFS}}" )

	[[ "${haystack[*]}" == *"${needle}"* ]]
}
has() { rindeal:has "${@}" ; }

rindeal:has_version() {
	local atom root root_arg
	local -a cmd=()
	case $1 in
		--host-root|-r|-d|-b)
			root_arg=$1
			shift ;;
	esac
	atom=$1
	shift
	[ $# -gt 0 ] && die "${FUNCNAME[1]}: unused argument(s): $*"

	case ${root_arg} in
		"") if ___eapi_has_prefix_variables
			then
				root=${ROOT%/}/${EPREFIX#/}
			else
				root=${ROOT}
			fi ;;
		--host-root)
			if ! ___eapi_best_version_and_has_version_support_--host-root
			then
				die "${FUNCNAME[1]}: option ${root_arg} is not supported with EAPI ${EAPI}"
			fi
			if ___eapi_has_prefix_variables
			then
				# Since portageq requires the root argument be consistent
				# with EPREFIX, ensure consistency here (bug 655414).
				root=/${PORTAGE_OVERRIDE_EPREFIX#/}
				cmd+=(env EPREFIX="${PORTAGE_OVERRIDE_EPREFIX}")
			else
				root=/
			fi ;;
		-r|-d|-b)
			if ! ___eapi_best_version_and_has_version_support_-b_-d_-r
			then
				die "${FUNCNAME[1]}: option ${root_arg} is not supported with EAPI ${EAPI}"
			fi
			if ___eapi_has_prefix_variables
			then
				case ${root_arg} in
					-r) root=${ROOT%/}/${EPREFIX#/} ;;
					-d) root=${ESYSROOT} ;;
					-b)
						# Use /${PORTAGE_OVERRIDE_EPREFIX#/} which is equivalent
						# to BROOT, except BROOT is only defined in src_* phases.
						root=/${PORTAGE_OVERRIDE_EPREFIX#/}
						cmd+=(env EPREFIX="${PORTAGE_OVERRIDE_EPREFIX}")
						;;
				esac
			else
				case ${root_arg} in
					-r) root=${ROOT} ;;
					-d) root=${SYSROOT} ;;
					-b) root=/ ;;
				esac
			fi ;;
	esac

	### BEGIN: patched section
	# these variables cause the helpers mark `*::repo` expressions as invalid package atom
	cmd+=( env -u EBUILD_PHASE -u EAPI )
	### END: patched section

	if [[ -n $PORTAGE_IPC_DAEMON ]]
	then
		cmd+=("${PORTAGE_BIN_PATH}"/ebuild-ipc "${FUNCNAME[1]}" "${root}" "${atom}")
	else
		cmd+=("${PORTAGE_BIN_PATH}"/ebuild-helpers/portageq "${FUNCNAME[1]}" "${root}" "${atom}")
	fi
	"${cmd[@]}"
	local retval=$?
	case "${retval}" in
		0|1)
			return ${retval}
			;;
		2)
			die "${FUNCNAME[1]}: invalid atom: ${atom}"
			;;
		*)
			if [[ -n ${PORTAGE_IPC_DAEMON} ]]
			then
				die "${FUNCNAME[1]}: unexpected ebuild-ipc exit code: ${retval}"
			else
				die "${FUNCNAME[1]}: unexpected portageq exit code: ${retval}"
			fi
			;;
	esac
}
has_version() { rindeal:has_version "${@}" ; }

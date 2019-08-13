#!/bin/bash
#
# Editing this script should not be required.
#
# To specify additional VM options, add them to smartgit.vmoptions files.

declare -g -r -- APP_NAME="SmartGit"
declare -g -r -- RELEASE="19.1"
declare -g -r -- APP_CONFIG_DIR="${XDG_CONFIG_HOME:-"${HOME}/.config"}/${APP_NAME,,}/${RELEASE}"

loadVmOptions() {
	local -r -- file="${1}"
	[[ -f "${file}" ]] || return 1

	local -- line
	while read -r line
	do
		# remove leading whitespace characters
		line="${line#"${line%%[![:space:]]*}"}"

		if (( ${#line} <= 0 )) || [[ ${line:0:1} == '#' ]]
		then
			continue
		fi

		if [[ "${line}" == 'jre='* ]]
		then
			printf "Ignoring following line in file '${file}':\n"
			printf "%s\n" "${line}"
			continue
		fi

		if [[ "${line}" == 'path='* ]]
		then
			APP_PATH="${APP_PATH}:${line#*=}"
		else
			_VM_PROPERTIES+=" ${line}"
		fi
	done < "${file}"
}

# check system architecture
case "$(uname -m)" in
"x86_64" ) ;;
"aarch64" ) ;;
* )
	>&2 printf "%s\n" "${APP_NAME} is not supported any more on 32-bit systems."
	exit 1
esac

# Resolve the location of the SmartGit installation.
# This includes resolving any symlinks.
declare -g -r -- APP_BIN="$( realpath "$( dirname "$( realpath "${BASH_SOURCE[0]}" )" )" )"
declare -g -r -- APP_HOME="$( realpath "$( dirname "${APP_BIN}" )" )"

VMOPTIONS_FILENAME="${APP_NAME,,}.vmoptions"
loadVmOptions "${APP_BIN}/${VMOPTIONS_FILENAME}"
loadVmOptions "${HOME}/.${APP_NAME,,}/${VMOPTIONS_FILENAME}"
loadVmOptions "${APP_CONFIG_DIR}/${VMOPTIONS_FILENAME}"

# Determine Java Runtime
APP_JAVA_HOME="${SMARTGIT_JAVA_HOME}"
_JAVA_EXEC="java"
if [[ -n "${APP_JAVA_HOME}" ]]
then
	_TMP="${APP_JAVA_HOME}/bin/java"
	if [[ -f "${_TMP}" ]]
	then
		if [[ -x "${_TMP}" ]]
		then
			_JAVA_EXEC="${_TMP}"
		else
			>&2 printf "%s\n" "Warning: '${_TMP}' is not executable"
		fi
	else
		>&2 printf "%s\n" "Warning: '${_TMP}' does not exist"
	fi
elif [[ -e "${APP_HOME}/jre/bin/java" ]] && [[ "$(uname -m)" == "x86_64" ]]
then
	_JAVA_EXEC="${APP_HOME}/jre/bin/java"
fi

if ! command -v "${_JAVA_EXEC}" >/dev/null
then
	>&2 printf "%s\n" "Error: No Java Runtime Environment (JRE) 11 or higher found"
	mkdir --parents "${APP_CONFIG_DIR}" && \
		touch "${APP_CONFIG_DIR}/${VMOPTIONS_FILENAME}"
	exit 1
fi

if [[ "${XDG_CURRENT_DESKTOP}" == "Unity" ]]
then
	# work-around for https://bugs.eclipse.org/bugs/show_bug.cgi?id=419729
	# work-around for https://bugs.eclipse.org/bugs/show_bug.cgi?id=502056
	export UBUNTU_MENUPROXY=0

	# Without the following line sliders are not visible in Ubuntu 12.04
	# (see <https://bugs.eclipse.org/bugs/show_bug.cgi?id=368929>)
	export LIBOVERLAY_SCROLLBAR=0
fi

if [[ "${KDE_SESSION_UID}" != "" ]] && [[ "${GTK2_RC_FILES}" == "" ]]
then
	if grep -q "oxygen-gtk" "${HOME}/.gtkrc-2.0-kde4"
	then
		printf "%s\n" "Please change the GTK+ theme to something else than oxygen-gtk."
		printf "%s\n" "See also https://www.syntevo.com/blog/?p=4143"
		exit 1
	fi
fi

if [[ "${XDG_SESSION_TYPE}" == "wayland" ]]
then
	export GDK_BACKEND="x11"
fi

# work-around for https://bugs.eclipse.org/bugs/show_bug.cgi?id=542675
if [[ "${GTK_IM_MODULE}" == "xim" ]]
then
	export GTK_IM_MODULE="ibus"
fi

#export GTK_THEME=Adwaita
#export SWT_GTK3=0
if [[ "${SWT_GTK3}" != "0" ]]
then
	printf "%s\n" "If you experience strange GUI bugs or crashes, try setting GTK_THEME=Adwaita or SWT_GTK3=0."
fi

_GC_OPTS=(
	"-XX:+UseG1GC"
	"-XX:MaxGCPauseMillis=100"
	"-XX:InitiatingHeapOccupancyPercent=25"
	"-Xmx1024m"
	"-Xss2m"
)
_MISC_OPTS=(
	"-Xverify:none"
	"-XX:MaxJavaStackTraceDepth=1000000"
	"-Dsun.io.useCanonCaches=false"
	"-XX:ErrorFile=$APP_CONFIG_DIR/hs_err_pid%p.log"
)


export PATH="${PATH}${SMARTGIT_PATH:+":${SMARTGIT_PATH}"}"
exec "${_JAVA_EXEC}" ${_GC_OPTS[*]} ${_MISC_OPTS[*]} ${_VM_PROPERTIES} -jar "${APP_HOME}/lib/bootloader.jar" "${@}"

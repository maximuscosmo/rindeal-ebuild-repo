# Copyright 1999-2019 Gentoo Authors
# Copyright 2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: xdg.eclass
# @BLURB: Provides phases for XDG compliant packages.
# @DESCRIPTION:
# Utility eclass to update the desktop, icon and shared mime info as laid
# out in the freedesktop specs & implementations

case "${EAPI:-0}" in
'6' | '7' ) ;;
* ) die "Unsupported EAPI='${EAPI}' for '${ECLASS}'" ;;
esac
inherit rindeal


inherit xdg-utils


# Avoid dependency loop as both depend on glib-2
if [[ "${CATEGORY}/${P}" != "dev-libs/glib-2."* ]]
then
DEPEND="
	dev-util/desktop-file-utils
	x11-misc/shared-mime-info
"
fi


EXPORT_FUNCTIONS src_prepare pkg_preinst pkg_postinst pkg_postrm


# @FUNCTION: xdg_src_prepare
# @DESCRIPTION:
# Prepare sources to work with XDG standards.
xdg_src_prepare() {
	debug-print-function "${FUNCNAME[0]}"

	xdg_environment_reset

	default
}

# @FUNCTION: xdg_pkg_preinst
# @DESCRIPTION:
# Finds .desktop, icon and mime info files for later handling in pkg_postinst.
# Locations are stored in XDG_ECLASS_DESKTOPFILES, XDG_ECLASS_ICONFILES
# and XDG_ECLASS_MIMEINFOFILES respectively.
xdg_pkg_preinst() {
	debug-print-function "${FUNCNAME[0]}"

	local -A map=(
		['XDG_ECLASS_DESKTOPFILES']="usr/share/applications"
		['XDG_ECLASS_ICONFILES']="usr/share/icons"
		['XDG_ECLASS_MIMEINFOFILES']="usr/share/mime"
	)

	local -- var
	for var in "${!map[@]}"
	do
		local -- val="${map["${var}"]}"

		declare -g -a "${var}=( )"
		local -n arr="${var}"

		local -- f
		while IFS= read -r -d $'\0' f
		do
			arr+=( "${f}" )
		done < <(cd "${ED}" && find ${val} -type f -print0 2>/dev/null)
	done
}

_xdg_post_check_vars_defined() {
	_is_decl() {
		declare -p "${@}" &>/dev/null
	}

	if ! ( _is_decl XDG_ECLASS_DESKTOPFILES && _is_decl XDG_ECLASS_ICONFILES && _is_decl XDG_ECLASS_MIMEINFOFILES )
	then
		eqawarn "${FUNCNAME[0]}() called, but xdg_pkg_preinst() probably not"
	fi

	unset -f _is_decl
}

# @FUNCTION: xdg_pkg_postinst
# @DESCRIPTION:
# Handle desktop, icon and mime info database updates.
xdg_pkg_postinst() {
	debug-print-function "${FUNCNAME[0]}"

	_xdg_post_check_vars_defined

	if (( ${#XDG_ECLASS_DESKTOPFILES[@]} ))
	then
		xdg_desktop_database_update
	else
		debug-print "No .desktop files to add to database"
	fi

	if (( ${#XDG_ECLASS_ICONFILES[@]} ))
	then
		xdg_icon_cache_update
	else
		debug-print "No icon files to add to cache"
	fi

	if (( ${#XDG_ECLASS_MIMEINFOFILES[@]} ))
	then
		xdg_mimeinfo_database_update
	else
		debug-print "No mime info files to add to database"
	fi
}

# @FUNCTION: xdg_pkg_postrm
# @DESCRIPTION:
# Handle desktop, icon and mime info database updates.
xdg_pkg_postrm() {
	debug-print-function "${FUNCNAME[0]}"

	_xdg_post_check_vars_defined

	if (( ${#XDG_ECLASS_DESKTOPFILES[@]} ))
	then
		xdg_desktop_database_update
	else
		debug-print "No .desktop files to remove from database"
	fi

	if (( ${#XDG_ECLASS_ICONFILES[@]} ))
	then
		xdg_icon_cache_update
	else
		debug-print "No icon files to remove from cache"
	fi

	if (( ${#XDG_ECLASS_MIMEINFOFILES[@]} ))
	then
		xdg_mimeinfo_database_update
	else
		debug-print "No mime info files to remove from database"
	fi
}

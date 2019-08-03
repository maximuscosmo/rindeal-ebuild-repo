# Copyright 2018-2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## functions: rindeal:has_version
inherit rindeal-utils

DESCRIPTION="Virtual package, please install 'dev-libs/glib:2::rindeal' instead"
HOMEPAGE="https://developer.gnome.org/gio/stable/gdbus-codegen.html https://gitlab.gnome.org/GNOME/glib"
LICENSE="no-source-code"

SLOT="0"

KEYWORDS="amd64 arm arm64"

S="${WORKDIR}"

RDEPEND="dev-libs/glib:2"

src_configure() { : ; }
src_compile()   { : ; }
src_install()   { : ; }

pkg_preinst() {
	if ! rindeal::has_version dev-libs/glib:2::rindeal
	then
		eerror ""
		eerror "This is a virtual package, which exists just to satisfy"
		eerror "dependency constraints of packages from the 'gentoo' repository."
		eerror "'gdbus-codegen' utility should've been installed from"
		eerror "the 'dev-libs/glib:2' package found in the 'rindeal' repository."
		eerror ""
		eerror "You have 2 options now:"
		eerror ""
		eerror "    1) Put these two lines into 'package.mask' file:"
		eerror ""
		eerror "        dev-libs/glib:2::gentoo"
		eerror "        ${CATEGORY}/${PN}::gentoo"
		eerror ""
		eerror "    2) Put these two lines into 'package.mask' file:"
		eerror ""
		eerror "        dev-libs/glib:2::rindeal"
		eerror "        ${CATEGORY}/${PN}::rindeal"
		eerror ""
		eerror "Otherwise you'll end up with no '${PN}',"
		eerror "which will cause subsequent builds to fail."
		eerror ""
		die "Package dev-libs/glib:2::rindeal not installed"
	fi
}

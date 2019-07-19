# Copyright 2018-2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

GITLAB_SERVER_URL="https://gitlab.gnome.org"
GITLAB_NAMESPACE="GNOME"
GITLAB_REF="v${PV}"

inherit gitlab

## EXPORPT_FUNCTIONS: src_prepare
## functions: vala_depend
inherit vala

## functions: eautoreconf
inherit autotools

## functions: prune_libtool_files
inherit ltprune

DESCRIPTION="Set of programs to inspect and build Windows Installer (.MSI) files"
HOMEPAGE="https://wiki.gnome.org/${PN} ${GITLAB_HOMEPAGE}"
LICENSE="LGPL-2+"

SLOT="0"
SRC_URI_A=( "${GITLAB_SRC_URI}" )

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( nls rpath gnu-ld )

CDEPEND_A=(
	"dev-libs/glib:2"
	"sys-apps/util-linux[libuuid]"
	"dev-libs/libxml2"
	"gnome-extra/libgsf[introspection]"
	"$(vala_depend)"
	"app-arch/gcab[vala]"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"virtual/yacc"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(  )
RESTRICT+=""

inherit arrays

src_prepare() {
	eapply_user

	vala_src_prepare

	eautoreconf
}

src_configure() {
	local my_econf_args=(
		### Fine tuning of the installation directories:

		### Optional Features:
		--enable-shared
		--disable-static
		$(use_enable nls)
		$(use_enable rpath)

		### Optional Packages:
		$(use_with gnu-ld)
	)
	econf "${my_econf_args[@]}"
}

src_install() {
	default

	prune_libtool_files
}

# Copyright 1999-2014 Gentoo Foundation
# Copyright 2016-2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## gitlab.eclass:
GITLAB_NS="rindeal-ns/abandonware"

## functions: gitlab:src_unpack
## variables: GITLAB_HOMEPAGE, GITLAB_SRC_URI
inherit gitlab

## EXPORT_FUNCTIONS: pkg_setup
inherit linux-info

## functions: eautoreconf
inherit autotools

## functions: prune_libtool_files
inherit ltprune

## functions: systemd_get_systemunitdir
inherit systemd

DESCRIPTION="Miredo is an open-source Teredo IPv6 tunneling software"
HOMEPAGE_A=(
	"${GITLAB_HOMEPAGE}"
	"http://www.remlab.net/miredo/"
)
LICENSE_A=( 'GPL-2.0-or-later' )

SLOT="0/6"
if [[ "${PV}" != *9999* ]]
then
	SRC_URI_A=(
		"${GITLAB_SRC_URI}"
	)
fi

if [[ "${PV}" != *9999* ]]
then
	KEYWORDS_A=(
		"amd64"
		"arm"
		"arm64"
	)
fi
IUSE_A=(
	+"caps"
	+"client"
	"nls"
	"assert"
	"judy"
)

CDEPEND_A=(
	"sys-devel/gettext"
	"sys-apps/iproute2"
	"virtual/udev"
	"caps? ( sys-libs/libcap )"
	"judy? ( dev-libs/judy )"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"app-arch/xz-utils"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	"acct-user/${PN}"
	"acct-group/${PN}"
)

inherit arrays

pkg_setup() {
	local -r -- CONFIG_CHECK="~IPV6 ~TUN"
	linux-info_pkg_setup
}

src_unpack() {
	gitlab:src_unpack
}

src_prepare() {
	default

	# the following step is normally done in `autogen.sh`
	rcp "${EPREFIX}"/usr/share/gettext/gettext.h "${S}"/include

	eautoreconf
}

src_configure() {
	local econf_args=(
		--disable-static
		--enable-miredo-user="miredo"
		--with-runstatedir="/run"
		--with-systemdsystemunitdir="$(systemd_get_systemunitdir)"

		$(use_enable assert)
		$(use_with caps libcap)
		$(use_enable client teredo-client)
		$(use_enable nls)
	)
	econf "${econf_args[@]}"
}

src_install() {
	default

	prune_libtool_files

	rrmdir "${ED}/run"

	insinto /etc/miredo
	doins misc/miredo-server.conf
}

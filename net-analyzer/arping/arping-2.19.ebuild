# Copyright 1999-2017 Gentoo Foundation
# Copyright 2017,2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## git-hosting.eclass:
GH_RN="github:ThomasHabets"
GH_REF="arping-${PV}"

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting

## EXPORT_FUNCTIONS: pkg_postinst
## variables: FILECAPS
inherit fcaps

## functions: eautoreconf
inherit autotools

DESCRIPTION="A utility to see if a specific IP address is taken and what MAC address owns it"
HOMEPAGE="http://www.habets.pp.se/synscan/programs.php?prog=arping ${GH_HOMEPAGE}"
LICENSE="GPL-2"

SLOT="$(ver_cut 1)"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE="test"

CDEPEND_A=(
	"net-libs/libpcap"
	"net-libs/libnet:1.1"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"test? ( dev-libs/check )"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	"!net-misc/iputils[arping(+)]"
)

inherit arrays

src_prepare() {
	default

	eautoreconf
}

src_configure() {
	local myeconf_opts=(
	)
	econf "${myeconf_opts[@]}"
}

FILECAPS=( cap_net_raw /usr/sbin/arping )

# Copyright 1999-2016 Gentoo Foundation
# Copyright 2018-2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## functions: eautoreconf
inherit autotools

## functions: prune_libtool_files
inherit ltprune

DESCRIPTION="Supporting tools for IMA and EVM"
HOMEPAGE="http://linux-ima.sourceforge.net"
LICENSE="GPL-2"

SLOT="0"
SRC_URI="mirror://sourceforge/linux-ima/${P}.tar.gz"

CDEPEND_A=(
	"sys-apps/keyutils"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"app-text/docbook-xsl-stylesheets"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
)

KEYWORDS="amd64 x86"
IUSE_A=( debug )

inherit arrays

src_prepare() {
	eapply_user

	eautoreconf
}

src_configure() {
	econf $(use_enable debug)
}

src_install() {
	default

	prune_libtool_files
}

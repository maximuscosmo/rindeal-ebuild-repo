# Copyright 1999-2016 Gentoo Foundation
# Copyright 2016-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

# original work by stefan-gr (https://github.com/stefan-gr), the maintainer of abendbrot overlay

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="github:cmdrkotori"
GH_REF="v${PV}"

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting

## EXPORT_FUNCTIONS: src_prepare pkg_preinst pkg_postinst pkg_postrm
inherit xdg

## functions: eqmake5
inherit qmake-utils

## functions: doicon
inherit desktop

DESCRIPTION="Media Player Classic - Qute Theater; MPC-HC reimplemented using mpv/Qt"
LICENSE="GPL-2"

SLOT="0"

KEYWORDS="~amd64"

CDEPEND_A=(
	">=media-video/mpv-0.18.0:0=[libmpv]"
	"dev-qt/qtcore:5"
	"dev-qt/qtgui:5"
	"dev-qt/qtnetwork:5"
	"dev-qt/qtwidgets:5"
	"dev-qt/qtx11extras:5"
	"dev-qt/qtdbus:5"
	"virtual/opengl:0"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"virtual/pkgconfig"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

src_configure() {
	eqmake5
}

src_install() {
	dobin "${PN}"

	doicon -s scalable "images/icon/${PN}.svg"

	einstalldocs
}

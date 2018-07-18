# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="github:Zren:plasma-applet-eventcalendar"
GH_REF="v${PV}"

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting

DESCRIPTION="Plasmoid for a calendar+agenda with weather that syncs to Google Calendar"
HOMEPAGE="https://store.kde.org/p/998901/ ${GH_HOMEPAGE}"
LICENSE="GPL-3"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( )

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}"
	"kde-plasma/plasma-workspace:5"
	"dev-qt/qtgraphicaleffects:5"
)

REQUIRED_USE_A=(  )
RESTRICT+=""

inherit arrays

src_install() {
	local instdir="${ED}/usr/share/plasma/plasmoids/org.kde.plasma.eventcalendar"

	einstalldocs

	cd "package" || die

	rmkdir "${instdir}"
	rcp -r * "${instdir}"
}

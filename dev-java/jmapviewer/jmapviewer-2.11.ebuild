# Copyright 2017,2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## java-pkg-2.eclass:
EANT_BUILD_TARGET="build pack"

## EXPORT_FUNCTIONS: pkg_setup src_prepare src_compile pkg_preinst
inherit java-pkg-2

## EXPORT_FUNCTIONS: src_configure
inherit java-ant-2

DESCRIPTION="Java OpenStreetMap Tile Viewer"
HOMEPAGE="https://wiki.openstreetmap.org/wiki/JMapViewer"
LICENSE="GPL-2"

SLOT="0"
SRC_URI_A=(
	# Upstream doesn't provide versioned tarballs so check for debian tarballs at:
	#
	#     https://snapshot.debian.org/package/jmapviewer/
	#
	"https://snapshot.debian.org/archive/debian/20190709T100457Z/pool/main/j/jmapviewer/jmapviewer_2.11%2Bdfsg.orig.tar.xz"
)

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( )

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}"
	">=virtual/jdk-1.8"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	">=virtual/jre-1.8"
)

RESTRICT+=" mirror"

inherit arrays

src_prepare() {
	default

	java-pkg-2_src_prepare

	# required for ant build task
	rmkdir bin
}

src_install() {
	java-pkg_dojar JMapViewer.jar
}

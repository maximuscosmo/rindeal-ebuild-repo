# Copyright 2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

GITHUB_NS="Matroska-Org"
GITHUB_REF="release-${PV}"

inherit github

## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
inherit cmake-utils

DESCRIPTION="C++ libary to parse EBML files"
HOMEPAGE_A=(
	"https://matroska-org.github.io/${PN}/"
	"${GITHUB_HOMEPAGE}"
)
LICENSE_A=(
	"LGPL-2.1-or-later"
)

libebml_soname_maj=4
SLOT="0/${libebml_soname_maj}"
SRC_URI_A=(
	"${GITHUB_SRC_URI}"
)

KEYWORDS="amd64 arm arm64"
IUSE_A=(  )

CDEPEND_A=( )
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(  )
RESTRICT+=""

inherit arrays

src_unpack()
{
	github:src_unpack
}

src_install()
{
	cmake-utils_src_install

	if ! [[ -e "${ED}/usr/$(get_libdir)/libebml.so.${libebml_soname_maj}" ]]
	then
		eqawarn "FIXME: libebml SONAME changed, please update ebuild subslot"
	fi
}

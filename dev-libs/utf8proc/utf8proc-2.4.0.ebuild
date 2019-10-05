# Copyright 2017-2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## github.eclass:
GITHUB_NS="JuliaLang"
GITHUB_REF="v${PV}"

##
inherit github

## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
inherit cmake-utils

DESCRIPTION="C library for processing UTF-8 Unicode data"
HOMEPAGE_A=(
	"https://juliastrings.github.io/utf8proc/"
	"${GITHUB_HOMEPAGE}"
)
LICENSE_A=(
	"MIT"
	"unicode"
)

# ABI version defined in `Makefile` or `CMakeLists.txt`
libutf8proc_ABI_version="2.3.1"
SLOT="0/${libutf8proc_ABI_version}"

SRC_URI_A=(
	"${GITHUB_SRC_URI}"
)

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( )

inherit arrays

src_unpack()
{
	github:src_unpack
}

src_prepare()
{
	# GNUInstallDirs support
	# https://github.com/JuliaStrings/utf8proc/pull/159
	eapply "${FILESDIR}/159.patch"

	eapply_user

# 	rsed -e '/include.*utils.cmake/a include(GNUInstallDirs)'  -i -- CMakeLists.txt
	rsed -r -e '/COMPILE_FLAGS/ s,-(O[0-9]|pedantic),,g' -i -- CMakeLists.txt
	rsed -e '/add_library/ s,$, SHARED,' -i -- CMakeLists.txt
	rsed -e '/SOVERSION/ s,$, PUBLIC_HEADER utf8proc.h,' -i -- CMakeLists.txt
	echo 'install(TARGETS utf8proc LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR} PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})' >> CMakeLists.txt || die

	cmake-utils_src_prepare
}

src_install() {
	cmake-utils_src_install

	dodoc NEWS.md
}

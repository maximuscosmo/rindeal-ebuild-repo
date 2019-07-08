# Copyright 2016-2017,2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## git-hosting.eclass:
GH_RN='github:fcambus'

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting

## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
inherit cmake-utils

DESCRIPTION='Web log analyzer using probabilistic data structures'
LICENSE='BSD-2'

SLOT='0'

KEYWORDS='~amd64 ~arm ~arm64'
IUSE_A=( )

CDEPEND_A=(
	"dev-libs/libmaxminddb:0"
	"dev-libs/jansson:0"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"virtual/pkgconfig"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

src_prepare() {
	eapply_user

	# https://github.com/fcambus/logswan/pull/12
	rsed -r -e '/^add_definitions/ s,(-Werror|-pedantic),,g' -i -- CMakeLists.txt

	cmake-utils_src_prepare
}

# Copyright 2016, 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="github:aitjcize"
# GH_REF="ccd4824"

## python-*.eclass:
PYTHON_COMPAT=( python3_{5,6,7} )
PYTHON_REQ_USE="sqlite"

## distutils-r1.eclass:
DISTUTILS_SINGLE_IMPL=true

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting

## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
inherit distutils-r1

DESCRIPTION="C++ man pages for Linux, with source from cplusplus.com and cppreference.com"
LICENSE="GPL-3"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( )

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}"
	"sys-apps/groff:0"
	"dev-python/beautifulsoup:4[${PYTHON_USEDEP}]"
	"dev-python/html5lib[${PYTHON_USEDEP}]"
)

REQUIRED_USE_A=(  )
RESTRICT+=""

inherit arrays

python_prepare_all() {
	eapply_user

	rsed -e 's|echo -e |printf |g' -i -- cppman/lib/pager.sh

	distutils-r1_python_prepare_all
}

# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="github:jonathanslenders:python-prompt-toolkit"

## python-*.eclass:
PYTHON_COMPAT=( python2_7 python3_{5,6} )

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting

## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
inherit distutils-r1

DESCRIPTION="Building powerful interactive command lines in Python"=
LICENSE="BSD"

SLOT="0"

KEYWORDS="amd64 ~arm ~arm64"
IUSE_A=( test )

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}"
	"dev-python/setuptools[${PYTHON_USEDEP}]"
	"test? ( dev-python/pytest[${PYTHON_USEDEP}] )"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	">=dev-python/six-1.9.0[${PYTHON_USEDEP}]"
	"dev-python/wcwidth[${PYTHON_USEDEP}]"
)

inherit arrays

python_test() {
	py.test || die
}

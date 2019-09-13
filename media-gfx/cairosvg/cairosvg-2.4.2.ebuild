# Copyright 1999-2015 Gentoo Foundation
# Copyright 2017-2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## github.eclass:
GITHUB_NS="Kozea"
GITHUB_PROJ="CairoSVG"

## python-*.eclass:
PYTHON_COMPAT=( python3_{5,6,7} )

## functions: github:src_unpack
## variables: GITHUB_SRC_URI, GITHUB_HOMEPAGE
inherit github

## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
## functions: distutils-r1_python_prepare_all
inherit distutils-r1

DESCRIPTION="Simple cairo based SVG converter with support for PDF, PostScript and PNG"
HOMEPAGE_A=(
	"https://cairosvg.org/"
	"${GITHUB_HOMEPAGE}"
)
LICENSE="LGPL-3"

SLOT="0"

SRC_URI_A=(
	"${GITHUB_SRC_URI}"
)

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( )

CDEPEND_A=(
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"dev-python/setuptools[${PYTHON_USEDEP}]"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	"dev-python/cairocffi[${PYTHON_USEDEP}]"
	"dev-python/cssselect2[${PYTHON_USEDEP}]"
	"dev-python/defusedxml[${PYTHON_USEDEP}]"
	"dev-python/pillow[${PYTHON_USEDEP}]"
	"dev-python/tinycss2[${PYTHON_USEDEP}]"
)

inherit arrays

src_unpack() {
	github:src_unpack
}

python_prepare_all() {
	# do not install tests
	rrm -r "${PN}"/test_api.py

	distutils-r1_python_prepare_all
}

DOCS=( NEWS.rst README.rst )

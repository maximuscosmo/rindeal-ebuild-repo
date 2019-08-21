# Copyright 1999-2015 Gentoo Foundation
# Copyright 2017-2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## git-hosting.eclass:
GH_RN="github:Kozea:CairoSVG"

## python-*.eclass:
PYTHON_COMPAT=( python3_{5,6} )

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting

## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
inherit distutils-r1

DESCRIPTION="Simple cairo based SVG converter with support for PDF, PostScript and PNG"
HOMEPAGE="https://cairosvg.org/ ${GH_HOMEPAGE}"
LICENSE="LGPL-3"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( test )

CDEPEND_A=(
	"dev-python/cairocffi[${PYTHON_USEDEP}]"
	"dev-python/cssselect2[${PYTHON_USEDEP}]" # missing python3.7 support
	"dev-python/defusedxml[${PYTHON_USEDEP}]"
	"dev-python/pillow[${PYTHON_USEDEP}]"
	"dev-python/tinycss2[${PYTHON_USEDEP}]" # missing python3.7 support

)
DEPEND_A=(
	"${CDEPEND_A[@]}"
	"dev-python/setuptools[${PYTHON_USEDEP}]"
	"test? ("
		"dev-python/pytest-runner[${PYTHON_USEDEP}]"
		"dev-python/pytest-cov[${PYTHON_USEDEP}]"
		"dev-python/pytest-flake8[${PYTHON_USEDEP}]"
		"dev-python/pytest-isort[${PYTHON_USEDEP}]"
	")"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

DOCS=( NEWS.rst README.rst )

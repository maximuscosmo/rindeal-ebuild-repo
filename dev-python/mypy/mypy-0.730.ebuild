# Copyright 1999-2017 Gentoo Foundation
# Copyright 2017-2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## git-hosting.eclass:
GH_RN="github:python"
GH_REF="v${PV}"

## python-*.eclass:
PYTHON_COMPAT=( python3_{5,6,7} )

## EXPORT_FUNCTIONS: src_unpack
## variables: GH_HOMEPAGE
inherit git-hosting

## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
## functions: distutils-r1_python_prepare_all, distutils-r1_python_install_all
## variables: PYTHON_USEDEP
inherit distutils-r1

DESCRIPTION="Optional static typing for Python"
HOMEPAGE_A=(
	"http://www.mypy-lang.org/"
	"${GH_HOMEPAGE}"
)
LICENSE="MIT"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE="doc test"

CDEPEND_A=( )
DEPEND_A=( "${CDEPEND_A[@]}"
	"doc? ("
		"dev-python/sphinx[${PYTHON_USEDEP}]"
		"dev-python/sphinx_rtd_theme[${PYTHON_USEDEP}]"
	")"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	# NOTE > remember to bump < NOTE
	"~dev-python/typeshed-0.0.0.0_p20190708"
	# NOTE ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ NOTE
	">=dev-python/typed-ast-1.4.0[${PYTHON_USEDEP}]"
	"<dev-python/typed-ast-1.5.0[${PYTHON_USEDEP}]"
	"$(python_gen_cond_dep \
		'>=dev-python/typing-extensions-3.7.4[${PYTHON_USEDEP}]' \
			'python3_5' 'python3_6'
	)"
	">=dev-python/mypy_extensions-0.4.0[${PYTHON_USEDEP}]"
	"<dev-python/mypy_extensions-0.5.0[${PYTHON_USEDEP}]"
)

inherit arrays

python_prepare_all() {
	rsed -r -e "/typeshed_dir = os.path/ s| = .*| = os.path.join('/', '${EPREFIX}', 'usr', 'share', 'typeshed')|" \
		-i -- "${PN}/build.py"

	distutils-r1_python_prepare_all
}

python_compile_all() {
	use doc && \
		emake -C docs html
}

python_install_all() {
	use doc && local HTML_DOCS=( docs/build/html/. )

	dosym ../../share/typeshed /usr/lib/${PN}/typeshed

	distutils-r1_python_install_all
}

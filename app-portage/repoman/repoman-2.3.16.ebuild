# Copyright 1999-2018 Gentoo Foundation
# Copyright 2018-2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## git-hosting.eclass:
GH_RN="gentoo:proj:portage.git"
GH_REF="${P}"

## python-*.eclass:
PYTHON_COMPAT=( python2_7 python3_{5,6,7} )
PYTHON_REQ_USE='bzip2(+)'

## EXPORT_FUNCTIONS: src_unpack
## variables: GH_HOMEPAGE
inherit git-hosting

## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
## variables: PYTHON_USEDEP
inherit distutils-r1

DESCRIPTION="Repoman is a Quality Assurance tool for Gentoo ebuilds"
HOMEPAGE="https://wiki.gentoo.org/wiki/Project:Portage ${GH_HOMEPAGE}"
LICENSE="GPL-2"

SLOT="0"

KEYWORDS="amd64 arm arm64"
IUSE_A=( )

CDEPEND_A=(
	">=sys-apps/portage-2.3.43[${PYTHON_USEDEP}]"
	">=dev-python/lxml-3.6.0[${PYTHON_USEDEP}]"
	"dev-python/pyyaml[${PYTHON_USEDEP}]"
)
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

S+="/repoman"

python_prepare_all() {
	# do not install tests that are never used at runtime
	rsed -e "/if '__init__.py' in filenames/ s@:\$@ and '/tests' not in dirpath:@" -i -- setup.py

	rsed -e '/gentooheader/d' -i -- cnf/repository/repository.yaml

	rsed -e '/"ltprune": False,/d' -i -- lib/repoman/modules/linechecks/deprecated/inherit.py

	distutils-r1_python_prepare_all
}

python_test() {
	esetup.py test
}

python_install() {
	local my_args=(
		--system-prefix="${EPREFIX}/usr"
		--bindir="$(python_get_scriptdir)"
		--docdir="${EPREFIX}/usr/share/doc/${PF}"
		--htmldir="${EPREFIX}/usr/share/doc/${PF}/html"
		--sbindir="$(python_get_scriptdir)"
		--sysconfdir="${EPREFIX}/etc"
	)

	distutils-r1_python_install "${my_args[@]}" "${@}"
}

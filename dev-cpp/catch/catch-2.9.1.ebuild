# Copyright 1999-2017 Gentoo Foundation
# Copyright 2017-2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## git-hosting.eclass:
GH_RN="github:catchorg:Catch2"
GH_REF="v${PV}"

## EXPORT_FUNCTIONS: src_unpack
## variables: GH_HOMEPAGE, SRC_URI
inherit git-hosting

## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
inherit cmake-utils

DESCRIPTION="Modern C++ header-only framework for unit-tests"
HOMEPAGE_A=(
	"${GH_HOMEPAGE}"
)
LICENSE="Boost-1.0"

SLOT="2"
SRC_URI_A=(
	"${SRC_URI}"
)

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=(
	doc contrib
)

inherit arrays

src_configure() {
	local -a mycmakeargs=(
		-D CATCH_USE_VALGRIND=OFF
		-D CATCH_BUILD_TESTING=OFF
		-D CATCH_BUILD_EXAMPLES=OFF
		-D CATCH_BUILD_EXTRA_TESTS=OFF
		-D CATCH_ENABLE_COVERAGE=OFF
		-D CATCH_ENABLE_WERROR=OFF
		-D CATCH_INSTALL_DOCS=$(usex doc ON OFF)
		-D CATCH_INSTALL_HELPERS=$(usex contrib ON OFF)
	)
	cmake-utils_src_configure
}

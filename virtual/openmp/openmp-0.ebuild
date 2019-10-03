# Copyright  2019  Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## functions: tc-check-openmp
inherit toolchain-funcs

DESCRIPTION="Virtual for OpenMP implementation"
# HOMEPAGE=
# LICENSE=

SLOT="0"
# SRC_URI=

KEYWORDS="amd64 arm arm64"
# IUSE=

DEPEND="
	|| (
		sys-devel/gcc:*[openmp]
		sys-libs/libomp:*
	)
"
RDEPEND="${DEPEND}"

S="${WORKDIR}"

src_unpack(){ :;}
src_configure(){
	tc-check-openmp
}
src_compile(){ :;}
src_test(){ :;}
src_install(){ :;}

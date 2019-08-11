# Copyright 2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## git-hosting.eclass:
GH_RN="github:zsh-users"
GH_REF="v${PV}"

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting

DESCRIPTION="Fish-like autosuggestions for zsh"
HOMEPAGE_A=(
	"${GH_HOMEPAGE}"
)
LICENSE="MIT"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=()

CDEPEND_A=(
)
DEPEND_A=( "${CDEPEND_A[@]}"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	"app-shells/zsh:*"
)

inherit arrays

src_configure() { :; }
src_compile() { :; }

src_install() {
	insinto /usr/share/zsh-autosuggestions
	doins zsh-autosuggestions.zsh

	einstalldocs
}

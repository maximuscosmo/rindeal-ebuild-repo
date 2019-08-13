# Copyright 2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## github.eclass:
GITHUB_NS="zsh-users"
GITHUB_REF="v${PV}"

## variables: GITHUB_HOMEPAGE, GITHUB_SRC_URI
## functions: github:src_unpack
inherit github

DESCRIPTION="Fish-like autosuggestions for zsh"
HOMEPAGE_A=(
	"${GITHUB_HOMEPAGE}"
)
LICENSE="MIT"

SLOT="0"
SRC_URI_A=(
	"${GITHUB_SRC_URI}"
)

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

src_unpack() {
	github:src_unpack
}

src_configure() { :; }
src_compile() { :; }

src_install() {
	insinto /usr/share/zsh-autosuggestions
	doins zsh-autosuggestions.zsh

	einstalldocs
}

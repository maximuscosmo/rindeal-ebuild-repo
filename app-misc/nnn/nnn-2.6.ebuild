# Copyright 2018-2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## git-hosting.eclass:
GH_RN="github:jarun"
GH_REF="v${PV}"

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting

## functions: tc-export
inherit toolchain-funcs

## functions: newbashcomp
inherit bash-completion-r1

DESCRIPTION="The missing terminal file browser for X"
LICENSE="GPL-2"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( +unicode +readline )

CDEPEND_A=(
	"sys-libs/ncurses:0=[unicode?]"
	"sys-libs/readline:0"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"virtual/pkgconfig:0"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

src_compile() {
	tc-export CC
	emake CFLAGS_OPTIMIZATION= $(usex readline '' norl)
}

src_install() {
	dobin "${PN}"
	doman "${PN}.1"

	# TODO: plugins
	# TODO: scripts

	einstalldocs

	## bash completion
	newbashcomp misc/auto-completion/bash/nnn-completion.bash "${PN}"

	## fish completion
	insinto /usr/share/fish/vendor_completions.d
	doins misc/auto-completion/fish/"${PN}".fish

	## zsh completion
	insinto /usr/share/zsh/site-functions
	doins misc/auto-completion/zsh/_"${PN}"
}

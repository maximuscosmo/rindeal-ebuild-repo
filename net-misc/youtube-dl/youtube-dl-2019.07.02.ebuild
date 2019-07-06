# Copyright 1999-2017 Gentoo Foundation
# Copyright 2017-2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## git-hosting.eclass:
GH_RN="github:rg3"

## python-*.eclass
PYTHON_COMPAT=( python2_7 python3_{5,6,7} )

## functions: newbashcomp
inherit bash-completion-r1

## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
## functions: distutils-r1_python_install_all
inherit distutils-r1

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting

DESCRIPTION="Download videos from YouTube.com (and more sites...)"
LICENSE="public-domain"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( +man test rtmp )

CDEPEND_A=(
	"dev-python/setuptools[${PYTHON_USEDEP}]"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"man? ("
		"|| ("
			"app-text/pandoc-bin"
			"app-text/pandoc"
		")"
	")"
	"test? ( dev-python/nose[coverage(+)] )"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	"rtmp? ( media-video/rtmpdump )"
)

inherit arrays

python_compile_all() {
	local emake_args=(
		V=1
		bash-completion
		zsh-completion
		fish-completion
		$(use man && echo ${PN}.1 README.txt)
	)
	emake "${emake_args[@]}"
}

python_test() {
	emake test
}

python_install_all() {
	if use man
	then
		doman ${PN}.1
		dodoc README.txt
	fi

	newbashcomp ${PN}.bash-completion ${PN}

	insinto /usr/share/zsh/site-functions
	newins youtube-dl.zsh _youtube-dl

	insinto /usr/share/fish/completions
	doins youtube-dl.fish

	distutils-r1_python_install_all

	rrm -r "${ED}"/usr/etc
	rrm -r "${ED}"/usr/share/doc/youtube_dl
}

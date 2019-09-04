# Copyright 1999-2016 Gentoo Foundation
# Copyright 2016-2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## github.eclass:
GITHUB_NS="ckolivas"
GITHUB_REF="e612a65"  # Oct 23, 2016

## uses are self-explanatory
inherit github

## functions: tc-getCC
inherit toolchain-funcs

DESCRIPTION="Con Kolivas' Linux Interactivity Benchmark"
HOMEPAGE_A=(
	"${GITHUB_HOMEPAGE}"
)
LICENSE="GPL-2"

SLOT="0"
SRC_URI_A=(
	"${GITHUB_SRC_URI}"
)

KEYWORDS="~amd64 ~arm ~arm64"

inherit arrays

src_unpack() {
	github:src_unpack
}

src_prepare() {
	default

	# do not hardcode sched_priority (taken from FreeBSD Ports)
	rsed -e 's|sched_priority = 99|sched_priority = sched_get_priority_max(SCHED_FIFO)|' \
		-e 's|set_fifo(96)|set_fifo(sched_get_priority_max(SCHED_FIFO) - 1)|' \
		-e 's|\(set_thread_fifo(thi->pthread,\) 95|\1 sched_get_priority_max(SCHED_FIFO) - 1|' \
		-i -- ${PN}.c
}

src_compile() {
	emake CC="$(tc-getCC)" CFLAGS="${CFLAGS}"
}

src_install() {
	dobin "${PN}"

	doman "${PN}.8"

	dodoc "readme" "readme.interactivity"
}

# Copyright 1999-2015 Gentoo Foundation
# Copyright 2016-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## functions: eutoreconf
inherit autotools

## functions: prune_libtool_files
inherit ltprune

## functions: get_bashcompdir
inherit bash-completion-r1

DESCRIPTION="Firmware Test Suite (ACPI, BIOS, UEFI, ...)"
HOMEPAGE="https://wiki.ubuntu.com/Kernel/Reference/fwts"
LICENSE="GPL-2"

SLOT="0"
# get newest release:
#
#     wget -q -O - "http://archive.ubuntu.com/ubuntu/pool/universe/f/fwts/?C=M;O=D" | grep orig.tar | head -n 1 | grep -P -o '(?<=">)[^<>]+(?=</a)'
#
SRC_URI="https://launchpad.net/ubuntu/+archive/primary/+files/${PN}_${PV}.orig.tar.gz"

KEYWORDS="~amd64"
IUSE=""

CDEPEND_A=(
	"sys-apps/dtc:0"  # libfdt
	"sys-apps/pciutils"  # libpci, pci/pci.h

	">=dev-libs/json-c-0.10-r1"
	"dev-libs/glib:2"  # pkg-config --cflags glib-2.0 gio-2.0
)
DEPEND_A=(
	"${CDEPEND_A[@]}"
	"virtual/pkgconfig"
	"sys-devel/libtool"  # AC_PROG_LIBTOOL
	"sys-devel/flex"  # AC_PROG_LEX
	"sys-devel/bison"
	"virtual/yacc"  # AC_PROG_YACC
	"sys-kernel/linux-headers"  # mtd/mtd-abi.h
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	# `gentoo` repo pkg name
	"!sys-apps/fwts"

	"sys-apps/dmidecode"  # used in dump logs
)

inherit arrays

S="${WORKDIR}"

src_prepare(){
	eapply_user

	grep -r --files-with-matches ' -Werror' | xargs sed -e 's| -Werror||' -i --
	assert

	rsed -e 's:/usr/bin/lspci:'$(type -p lspci)':' \
		-i -- src/lib/include/fwts_binpaths.h

	# Fix json-c includes
	rsed -e 's|^#include <json.h>|#include <json-c/json.h>|' \
		-i -- src/lib/include/fwts_json.h src/utilities/kernelscan.c

	eautoreconf

	# Sandbox fails due to https://bugs.gentoo.org/show_bug.cgi?id=598810,
	# because bash executes the globs inside $_G_message.
	# Specific content that fails is: https://pastebin.com/B4kgCYpJ.
	rsed -e 's|for _G_line in $_G_message; do|for _G_line in "$_G_message"; do|' -i -- ltmain.sh
}

src_configure() {
	econf --disable-static --with-bashcompletiondir="$(get_bashcompdir)"
}

src_install() {
	default

	dobin "live-image/fwts-frontend-text"
	dobin "scripts/fwts-collect"

	prune_libtool_files
}

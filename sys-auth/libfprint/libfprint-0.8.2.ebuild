# Copyright 1999-2016 Gentoo Foundation
# Copyright 2016-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## EXPORT_FUNCTIONS: src_unpack
inherit vcs-snapshot

## functions: get_udevdir
inherit udev

## EXPORT_FUNCTIONS: src_configure src_compile src_test src_install
inherit meson

inherit flag-o-matic

DESCRIPTION="Library for fingerprint reader support"
HOMEPAGE="https://cgit.freedesktop.org/${PN}/${PN}"
LICENSE="LGPL-2.1"

# NOTE: upstream changes case of the 'v' letter from time to time
MY_PV="V_${PV//./_}"
SLOT="0"
SRC_URI="https://gitlab.freedesktop.org/${PN}/${PN}/-/archive/${MY_PV}/${P}.tar.bz2"

# no arm until profiles are set up
KEYWORDS="~amd64"
IUSE_A=( doc examples validity-driver )

CDEPEND_A=(
	"virtual/libusb:1"
	"dev-libs/glib:2"
	"dev-libs/nss"
	"x11-libs/pixman"
	"virtual/udev"
	"examples? ("
		"x11-libs/libX11:0"
		"x11-libs/libXv:0"
	")"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"virtual/pkgconfig"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	"amd64? ( validity-driver? ( sys-auth/validity-sensor ) )"
)

inherit arrays

src_prepare() {
	eapply_user

	rsed -e "/mathlib_dep *=/a libdl_dep = cc.find_library('dl')" -i -- meson.build

	if use validity-driver ; then
		rcp -r "${FILESDIR}/validity-driver" "libfprint/drivers/validity"
# 		eapply "${FILESDIR}/vcsFPService_driver.patch"
		rsed -r -e "/^all_drivers *=/ s|(]$)|, 'validity'\1|" -i -- meson.build
		local validity_driver="$(
			echo -n "    if driver == 'validity'\n"
			echo -n "        drivers_sources += [ 'drivers/validity/vfsDriver.c', 'drivers/validity/vfsDriver.h' , 'drivers/validity/vfsWrapper.h' ]\n"
			echo -n "    endif\n"
		)"
		rsed -e "/foreach driver: drivers/a \\${validity_driver}" -i -- libfprint/meson.build
		rsed -r -e "/deps *=/ s|(]$)|, libdl_dep\1|" -i -- libfprint/meson.build
	fi

	use examples || rsed -e "/subdir('examples')/d" -i -- meson.build
}

src_configure() {
	if use validity-driver ; then
		append-cflags -Wno-format-zero-length
	fi

	local emesonargs=(
		# TODO: split to USE=all-drivers / USE=<driver> ...
		-D drivers=all
		-D udev_rules=true  # Whether to create a udev rules file
		-D udev_rules_dir="$(get_udevdir)/rules.d"
		$(meson_use examples x11-examples)
		$(meson_use doc)  # Whether to build the API documentation
	)

	meson_src_configure
}

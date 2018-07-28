# Copyright 1999-2017 Gentoo Foundation
# Copyright 2017-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## gnome2.eclass:
GNOME2_EAUTORECONF="yes"

## EXPORT_FUNCTIONS: src_unpack
inherit vcs-snapshot

## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_install pkg_preinst pkg_postinst pkg_postrm
inherit gnome2

## functions: optfeature
inherit eutils

DESCRIPTION="Gnome Partition Editor"
HOMEPAGE="https://gparted.sourceforge.io/ https://gitlab.gnome.org/GNOME/gparted"
LICENSE="GPL-2+ FDL-1.2+"

MY_P="${PN^^}_${PV//./_}"

SLOT="0"
SRC_URI="https://gitlab.gnome.org/GNOME/${PN}/-/archive/${MY_P}/${P}.tar.bz2"

KEYWORDS="~amd64"
IUSE_A=( doc libparted-dmraid nls kde +online-resize xhost-root)

CDEPEND_A=(
	"sys-apps/util-linux:0[libuuid]"
	">=sys-block/parted-3.2:="

	">=dev-cpp/glibmm-2.14:2"
	">=dev-cpp/gtkmm-2.22:2.4"
	">=dev-libs/glib-2:2"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	"kde? ( kde-plasma/kde-cli-tools[kdesu] )"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"app-text/docbook-xml-dtd:4.1.2"
	"doc? ( app-text/gnome-doc-utils )"
	"nls? ("
		"dev-util/intltool"
		"sys-devel/gettext"
	")"
	"virtual/pkgconfig"
)

RESTRICT+=" mirror"

inherit arrays

src_prepare() {
	eapply_user

	rsed -e "/^ *polkit_action_DATA/ s,=.*,=," -i -- Makefile.am

	gnome2_src_prepare
}

src_configure() {
	local my_econf_args=(
		--enable-shared
		--disable-static
		$(use_enable nls)
		$(use_enable doc)
		--disable-scrollkeeper  # do not make updates to the scrollkeeper database
		$(use_enable libparted-dmraid)
		$(use_enable online-resize)
		$(use_enable xhost-root)  # enable explicitly granting root access to the display

		GKSUPROG=$(type -P true)
	)
	gnome2_src_configure "${my_econf_args[@]}"
}

src_install() {
	gnome2_src_install

	if use kde ; then
		local _ddir="${ED}"/usr/share/applications

		rcp "${_ddir}"/gparted{,-kde}.desktop

		rsed -e 's:Exec=:Exec=kdesu5 :' -i -- "${_ddir}"/gparted-kde.desktop
		echo 'OnlyShowIn=KDE;' >> "${_ddir}"/gparted-kde.desktop || die
		echo 'NotShowIn=KDE;' >> "${_ddir}"/gparted.desktop || die
	fi
}

pkg_postinst() {
	gnome2_pkg_postinst

	## List of requirements in `Utils::get_filesystem_software()` in `src/Utils.cc`
	elog "Also install these utilities in order to support additional filesystems:"
	optfeature "btrfs"    "sys-fs/btrfs-progs"
	optfeature "ext2"     "sys-fs/e2fsprogs"
	optfeature "ext3"     "sys-fs/e2fsprogs"
	optfeature "ext4"     ">=sys-fs/e2fsprogs-1.41"
	optfeature "f2fs"     "sys-fs/f2fs-tools"
	optfeature "fat16"    "sys-fs/dosfstools"
	optfeature "fat32"    "sys-fs/dosfstools"
	optfeature "hfs"      "sys-fs/hfsutils"
# 	optfeature "hfs+"     "hfsprogs"
	optfeature "jfs"      "sys-fs/jfsutils"
	optfeature "swap"     "sys-apps/util-linux[mkswap,swapon]"
	optfeature "lvm2"     "sys-fs/lvm2"
	optfeature "luks"     "sys-fs/cryptsetup" "sys-fs/lvm2"
	optfeature "nilfs2"   "sys-fs/nilfs-utils"
	optfeature "ntfs"     "sys-fs/ntfs3g[ntfsprogs]"
	optfeature "reiser4"  "sys-fs/reiser4progs"
	optfeature "reiserfs" "sys-fs/reiserfsprogs"
	optfeature "udf"      "sys-fs/udftools"
# 	optfeature "ufs"      ""
	optfeature "xfs"      "sys-fs/xfsprogs" "sys-fs/xfsdump"
}

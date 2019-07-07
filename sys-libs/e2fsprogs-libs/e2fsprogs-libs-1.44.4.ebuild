# Copyright 1999-2018 Gentoo Foundation
# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## EXPORT_FUNCTIONS src_unpack src_prepare src_configure src_compile src_install
inherit e2fsprogs

## functions: gen_usr_ldscript
inherit toolchain-funcs

DESCRIPTION="e2fsprogs libraries (libcomm_err and libss)"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( )

CDEPEND_A=( )
DEPEND_A=( "${CDEPEND_A[@]}"
	"virtual/pkgconfig"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	"!sys-libs/com_err"
	"!sys-libs/ss"
	"!<sys-fs/e2fsprogs-1.41.8"
)

inherit arrays

src_prepare() {
	# TODO: remove this series of patches in ver > 1.44.4
	eapply "${FILESDIR}"/d16afd2cb65f6cc1e0522a11e7d5a50e5cfe9e36.patch
	eapply "${FILESDIR}"/ed07fd93056a2d2c03affe3255d3d5747deaab21.patch
	eapply "${FILESDIR}"/feb235e0812d6c5f1fda9e8c790b5bcb78aba285.patch

	eapply_user

	# TODO: this will be needed in ver > 1.44.4
# 	rrm config/ltmain.sh
# 	rcp /usr/share/libtool/build-aux/ltmain.sh config/ltmain.sh

	e2fsprogs_src_prepare
}

src_configure() {
	# do not check for these libs as they're not used in this minimal build
	export ac_cv_lib_{uuid_uuid_generate,blkid_blkid_get_cache}=yes

	e2fsprogs_src_configure --enable-subset
}

src_install() {
	e2fsprogs_src_install

	# We call "gen_usr_ldscript -a" to ensure libs are present in /lib to support
	# split /usr (e.g. "e2fsck" from sys-fs/e2fsprogs is installed in /sbin and
	# links to libcom_err.so).
	gen_usr_ldscript -a com_err ss

	# Package installs same header twice -- use symlink instead
	dosym et/com_err.h /usr/include/com_err.h
}
# Copyright 1999-2018 Gentoo Foundation
# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## EXPORT_FUNCTIONS src_unpack src_prepare src_configure src_compile src_install
inherit e2fsprogs

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
	eapply_user

	## this will create source tree similar to that in the upstream pre-generated archive
	local pattern patterns
	while read pattern ; do
		find .* * -regex "${pattern}" -print0 | xargs -0 --no-run-if-empty rm -r
		assert
	done < util/subset.exclude || die

	e2fsprogs_src_prepare
}

src_configure() {
	# do not check for these libs as they're not used in this minimal build
	export ac_cv_lib_{uuid_uuid_generate,blkid_blkid_get_cache}=yes

	e2fsprogs_src_configure
}

src_install() {
	e2fsprogs_src_install

	gen_usr_ldscript -a com_err ss
}

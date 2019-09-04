# Copyright 2004-2016 Sabayon
# Copyright 2017-2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

MY_PAGURE_PATCHES=(
	7acf0fa  # "files.c: Init char *name to NULL"
	8da7fc8  # "merge_ent_array_duplicates: Only use values if valid"
	e553684  # "editing_open: close fd after we've established its validity"
)

## pagure.eclass:
PAGURE_REF="${P}"

## uses are self-explanatory
inherit pagure

## functions: eautoreconf
inherit autotools

## functions: prune_libtool_files
inherit ltprune

DESCRIPTION="Standardized interface for manipulating and administering user/group accounts"
HOMEPAGE_A=(
	"${PAGURE_HOMEPAGE}"
)
LICENSE="GPL-2"

SLOT="0"
SRC_URI_A=(
	"${PAGURE_SRC_URI}"
)
for ref in "${MY_PAGURE_PATCHES[@]}"
do
	SRC_URI_A+=( "${PAGURE_HOMEPAGE}/c/${ref}.patch" )
done
unset ref

KEYWORDS="amd64 arm arm64"
IUSE_A=(
	+shared-libs static-libs nls

	+popt ldap sasl selinux audit
)

CDEPEND_A=(
	"dev-libs/glib:2="
	"dev-libs/openssl:0="
	"popt? ( dev-libs/popt )"
	"ldap? ( net-nds/openldap )"
	"sasl? ( dev-libs/cyrus-sasl )"
	"selinux? ( sys-libs/libselinux )"
	"audit? ( sys-process/audit:* )"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"virtual/yacc"
	"nls? ( sys-devel/gettext )"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

src_unpack() {
	pagure:src_unpack
}

src_prepare() {
	local -- ref
	for ref in "${MY_PAGURE_PATCHES[@]}"
	do
		eapply "${DISTDIR}/${ref}.patch"
	done

	eapply_user

	## change `man 1 lid` to `man 1 libuser-lid`
	rmv apps/{,libuser-}lid.1
	rsed -e 's@ apps/lid\.1 @ apps/libuser-lid.1 @' \
		-i -- Makefile.am

	## no docs
	sed -e "s|@sysconfdir@|${EPREFIX}/etc|g" -- "docs/libuser.conf.5.in" > "${T}/libuser.conf.5" || die
	rsed -e '/^SUBDIRS/ s| docs| |' -i -- Makefile.am
	rsed -r -e "s@\"?(^| )docs(/[^ ]*)\"?@@g" -i -- configure.ac
	NO_V=1 rrm -r docs

	eautoreconf
}

src_configure() {
	local -a my_econf_args=(
		--disable-Werror
		--enable-largefile
		--disable-rpath

		$(use_enable shared-libs shared)
		$(use_enable static-libs static)

		$(use_enable nls)

		--disable-gtk-doc
		--disable-gtk-doc-html
		--disable-gtk-doc-pdf

		$(use_with popt)
		$(use_with ldap)
		$(use_with sasl)
		--without-python # too much pain to implement, for no gain
		$(use_with selinux)
		$(use_with audit)
	)

	econf "${my_econf_args[@]}"
}

src_install() {
	default

	doman "${T}/libuser.conf.5"

	prune_libtool_files --modules
}

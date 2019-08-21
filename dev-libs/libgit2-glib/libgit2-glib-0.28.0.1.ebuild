# Copyright 2018-2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## gitlab.eclass:
GITLAB_SVR="https://gitlab.gnome.org"
GITLAB_NS="GNOME"
GITLAB_REF="v${PV}"

## python-*.eclass:
PYTHON_COMPAT=( python3_{5,6,7} )

## vala.eclass:
VALA_USE_DEPEND="vapigen"

## functions: gitlab:src_unpack
## variables: GITLAB_HOMEPAGE, GITLAB_SRC_URI
inherit gitlab

## EXPORT_FUNCTIONS: src_configure src_compile src_test src_install
inherit meson

## EXPORT_FUNCTIONS: src_prepare
## functions: vala_src_prepare, vala_depend
inherit vala

## functions: python_foreach_impl, python_moduleinto, python_domodule, python_get_sitedir
## variables: PYTHON_DEPS, PYTHON_USEDEP
inherit python-r1

DESCRIPTION="Glib wrapper library around the libgit2 git access library"
HOMEPAGE_A=(
	"https://developer.gnome.org/${PN}/"
	"${GITLAB_HOMEPAGE}"
	"https://github.com/${GITLAB_NS}/${PN}"
	"https://wiki.gnome.org/Projects/${PN^}"
)
LICENSE="LGPL-2+"

SLOT="0"

SRC_URI_A=(
	"${GITLAB_SRC_URI}"
)

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( introspection python ssh vala )

CDEPEND_A=(
	"dev-libs/glib:2"
	"dev-libs/libgit2:0/$(ver_cut 2)[ssh?]"
	"introspection? ( dev-libs/gobject-introspection:* )"
	"python? ("
		"${PYTHON_DEPS}"
		"dev-python/pygobject:3[${PYTHON_USEDEP}]"
	")"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"virtual/pkgconfig"
	"vala? ( $(vala_depend) )"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=( "vala? ( introspection )" )
RESTRICT+=""

inherit arrays

src_unpack() {
	gitlab:src_unpack
}

src_prepare() {
	eapply_user

	use vala && vala_src_prepare
}

src_configure() {
	local emesonargs=(
		# not thanks
		-Dgtk_doc=false
		# we install python scripts manually
		-Dpython=false
		$(meson_use introspection)
		$(meson_use ssh)
		$(meson_use vala vapi)
	)
	meson_src_configure
}

src_install() {
	meson_src_install

	if use python
	then
		install_gi_override() {
			python_moduleinto "$(python_get_sitedir)/gi/overrides"
			python_domodule "${S}"/${PN}/Ggit.py
		}
		python_foreach_impl install_gi_override
# 		python_moduleinto gi.overrides
# 		python_foreach_impl python_domodule libgit2-glib/Ggit.py
	fi
}

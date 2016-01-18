# Copyright (C) 2016; Jan Chren <dev.rindeal@outlook.com>
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGIT_REPO_URI="https://github.com/fsphil/fswebcam.git"
EGIT_BRANCH="master"

inherit git-r3

DESCRIPTION="A neat and simple webcam app"
HOMEPAGE="http://www.sanslogic.co.uk/fswebcam/"
LICENSE="GPL-2"
SRC_URI=""

SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE=""

DEPEND="media-libs/gd[jpeg,png,truetype]"
RDEPEND="${DEPEND}"

# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

inherit autotools git-r3 multilib

EGIT_REPO_URI="https://github.com/opdenkamp/xbmc-pvr-addons.git"

DESCRIPTION="XBMC addon: add VDR (http://www.cadsoft.de/vdr) as a TV/PVR Backend"
HOMEPAGE="https://github.com/opdenkamp/xbmc-pvr-addons"
SRC_URI=""

KEYWORDS="~amd64 ~x86"
LICENSE="GPL-2"
SLOT="0"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

S="${WORKDIR}/${P}"

src_prepare() {
	eautoreconf
}

src_configure() {
	econf --prefix=/usr \
		--libdir=/usr/share/xbmc/addons \
		--datadir=/usr/share/xbmc/addons
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
}

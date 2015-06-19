# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/xbmc-addon-xvdr/xbmc-addon-xvdr-9999.ebuild,v 1.2 2011/09/18 11:36:52 flameeyes Exp $

EAPI=5

inherit git-2 autotools multilib

GIT_REVISION="71e5b8c1da7acf726d00bde30da8554662cf97e1"
GIT_DATE="20140213"

EGIT_REPO_URI="git://github.com/opdenkamp/xbmc-pvr-addons.git"

DESCRIPTION="XBMC addon: add VDR (http://www.cadsoft.de/vdr) as a TV/PVR Backend"
HOMEPAGE="https://github.com/opdenkamp/xbmc-pvr-addons"
SRC_URI=""

KEYWORDS="~amd64 ~arm ~x86"
LICENSE="GPL-2"
SLOT="0"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

S=${WORKDIR}/${PN}

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

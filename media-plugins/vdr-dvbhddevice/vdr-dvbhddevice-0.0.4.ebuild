# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

inherit vdr-plugin

DESCRIPTION="VDR Plugin: output device for the 'Full Featured' DVB Card"
HOMEPAGE="http://www.tvdr.de/"
SRC_URI="http://dev.gentoo.org/~hd_brummy/distfiles/${P}.tar.gz"

KEYWORDS="~x86 ~amd64"
SLOT="0"
LICENSE="GPL-2"
IUSE=""

DEPEND=">=media-video/vdr-1.7.19"
RDEPEND="${DEPEND}
		media-tv/tt-s2-6400-firmware"

src_prepare() {
	vdr-plugin_src_prepare
#	epatch "${FILESDIR}/transfermode-0.0.4.diff"
#	epatch "${FILESDIR}/dag1-dag2-0.0.4.diff"

	fix_vdr_libsi_include dvbhdffdevice.c
}

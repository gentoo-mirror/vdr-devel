# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit vdr-plugin

DESCRIPTION="VDR Plugin: output device for the 'Full Featured' DVB Card"
HOMEPAGE="http://www.tvdr.de/"
SRC_URI="ftp://ftp.tvdr.de/vdr/Developer/vdr-1.7.19.tar.bz2"

KEYWORDS="~x86 ~amd64"
SLOT="0"
LICENSE="GPL-2"
IUSE=""

DEPEND=">=media-video/vdr-1.7.19"
RDEPEND="${DEPEND}"

S="${WORKDIR}/vdr-1.7.19/PLUGINS/src/${VDRPLUGIN}"

src_prepare() {
	vdr-plugin_src_prepare

#	use softosd && epatch "${FILESDIR}"/dvbsddevice_softosd_v1.diff
}

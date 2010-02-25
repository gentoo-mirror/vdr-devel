# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit vdr-plugin

DESCRIPTION="VDR Plugin: output device for the 'Full Featured' Card"
HOMEPAGE="http://www.tvdr.de/"
SRC_URI="ftp://ftp.tvdr.de/vdr/Developer/vdr-${PV}.tar.bz2"

KEYWORDS="~x86 ~amd64"
SLOT="0"
LICENSE="GPL-2"
IUSE="softosd"

DEPEND="=media-video/vdr-${PV}"
RDEPEND="${DEPEND}"

S="${WORKDIR}/vdr-${PV}/PLUGINS/src/${VDRPLUGIN}"

src_prepare() {
	vdr-plugin_src_prepare

	use softosd && epatch "${FILESDIR}"/dvbsddevice_softosd_v1.diff
}

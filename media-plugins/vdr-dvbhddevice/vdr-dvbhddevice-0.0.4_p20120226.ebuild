# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

inherit vdr-plugin

HG_REVISION="f5b9eb4182b9"
HG_REVISION_DATE="20120226"

DESCRIPTION="VDR Plugin: output device for the 'Full Featured' TechnoTrend
S2-6400 DVB Card"
HOMEPAGE="http://powarman.dyndns.org/hg/dvbhddevice"
SRC_URI="http://powarman.dyndns.org/hgwebdir.cgi/dvbhddevice/archive/${HG_REVISION}.tar.gz
-> dvbhddevice-0.0.4_p${HG_REVISION_DATE}.tar.gz"

KEYWORDS="~x86 ~amd64"
SLOT="0"
LICENSE="GPL-2"
IUSE=""

DEPEND=">=media-video/vdr-1.7.19"
RDEPEND="${DEPEND}"

S="${WORKDIR}/dvbhddevice-${HG_REVISION}"

src_prepare() {
	vdr-plugin_src_prepare

	epatch "${FILESDIR}/dvbhddevice-0.0.4_${HG_REVISION_DATE}_transfer.diff"

	fix_vdr_libsi_include dvbhdffdevice.c
}

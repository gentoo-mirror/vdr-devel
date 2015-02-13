# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/vdr-dvbhddevice/vdr-dvbhddevice-2.1.3_p20140115-r1.ebuild,v 1.1 2015/02/11 15:43:26 hd_brummy Exp $

EAPI=5

inherit mercurial vdr-plugin-2

EHG_REPO_URI="https://bitbucket.org/powARman/dvbhddevice"
EHG_REVISION="88cd727"
#hg_revision_date-> 20141116

DESCRIPTION="VDR Plugin: output device for the 'Full Featured' TechnoTrend
S2-6400 DVB Card"
HOMEPAGE="https://bitbucket.org/powARman/dvbhddevice"
SRC_URI=""

KEYWORDS="~amd64 ~x86"
SLOT="0"
LICENSE="GPL-2"
IUSE=""

DEPEND=">=media-video/vdr-2"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${VDRPLUGIN}-${EHG_REVISION}"

src_prepare() {
	vdr-plugin-2_src_prepare

	fix_vdr_libsi_include dvbhdffdevice.c

	if has_version ">=media-video/vdr-2.1.10"; then
		sed -e "s:pm = RenderPixmaps():pm = dynamic_cast<cPixmapMemory *>(RenderPixmaps()):"\
			-e "s:delete pm;:DestroyPixmap(pm);:"\
			-i hdffosd.c
	fi
}

src_install() {
	vdr-plugin-2_src_install

	doheader dvbhdffdevice.h hdffcmd.h

	insinto /usr/include/libhdffcmd
	doins libhdffcmd/*.h
}

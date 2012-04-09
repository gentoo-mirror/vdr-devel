# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

inherit vdr-plugin

DESCRIPTION="VDR Plugin: for the Reel eHD PCI card"
HOMEPAGE="http://www.reel-multimedia.com"
SRC_URI="http://vdr.websitec.de/download/${PN}/${P}.tgz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

S="${WORKDIR}/${PN}-3"

DEPEND=">=media-video/vdr-1.7.12
		>=media-video/reelbox-ehd-headers-${PV}
		media-video/ffmpeg
		media-libs/libmad
		media-libs/libpng
		media-libs/alsa-lib"
RDEPEND="${DEPEND}"

src_prepare() {
	vdr-plugin_src_prepare

	epatch "${FILESDIR}/reelbox-${PV}_makefile.diff"

	sed -i "${WORKDIR}"/bspshm/hostlib/bspshmlib.c \
		-e "s:\"../driver/bspshm.h\":<bspshm.h>:"

	sed -i "${WORKDIR}"/hdshm3/src/hostlib/hdshmlib.c \
		-e "s:\"../driver/hdshm.h\":<hdshm.h>:"

	epatch "${FILESDIR}/${P}_vdr-1.7.12-not-reelpatched.diff"

	sed -e "s:/dev/fb0:/dev/fb_reel:g" -i HdFbTrueColorOsd.c VideoPlayerPipHd.c

	sed -i Makefile -e "s:# -lswscale: -lswscale:g"

	# UINT64_C is needed by ffmpeg headers
	append-flags -D__STDC_CONSTANT_MACROS

	if has_version ">=media-video/vdr-1.7.27"; then
		epatch "${FILESDIR}/${P}_vdr-1.7.27.diff"
	fi

	epatch "${FILESDIR}/${P}_ffmpeg.diff"

	if has_version ">=media-libs/libpng-1.5"; then
		epatch "${FILESDIR}/${P}_libpng-1.5.diff"
	fi
}

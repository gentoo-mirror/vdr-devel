# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit vdr-plugin-2

DESCRIPTION="VDR Plugin: for the Reel eHD PCI card"
HOMEPAGE="http://www.reel-multimedia.com"
SRC_URI="http://vdr.websitec.de/download/${PN}/${P}.tgz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

S="${WORKDIR}/${PN}-3"

DEPEND=">=media-video/vdr-1.7.36
		>=media-video/reelbox-ehd-headers-${PV}
		virtual/ffmpeg
		media-libs/libmad
		media-libs/libpng:*
		media-libs/alsa-lib"
RDEPEND="${DEPEND}"

src_prepare() {
	rm "${S}"/po/{da_DK,el_GR,et_EE,fi_FI,fr_FR,hr_HR,hu_HU,nn_NO,pt_PT,ru_RU,sl_SI,sv_SE,tr_TR}.po

	cp "${FILESDIR}/${VDRPLUGIN}".mk "${S}"/Makefile

	vdr-plugin-2_src_prepare

	# remove i18n crap
	remove_i18n_include fs453settings.c reelbox.c
	sed -e "s:RegisterI18n://RegisterI18n:" -i reelbox.c

	sed -i "${WORKDIR}"/bspshm/hostlib/bspshmlib.c \
		-e "s:\"../driver/bspshm.h\":<bspshm.h>:"

	sed -i "${WORKDIR}"/hdshm3/src/hostlib/hdshmlib.c \
		-e "s:\"../driver/hdshm.h\":<hdshm.h>:"

	epatch "${FILESDIR}/${P}-v2_vdr-1.7.12-not-reelpatched.diff"

	sed -e "s:/dev/fb0:/dev/fb_reel:g" -i HdFbTrueColorOsd.c VideoPlayerPipHd.c

	epatch "${FILESDIR}/${P}_ffmpeg.diff"

	if has_version ">=media-libs/libpng-1.5"; then
		epatch "${FILESDIR}/${P}_libpng-1.5.diff"
	fi

	sed -e "s:avcodec_init://avcodec_init:" -i VideoPlayerPipHd.c

	# libav9 support
	epatch "${FILESDIR}/${P}_libav9-ffmpeg2.patch"
	sed -i \
		-e 's:avcodec.h>:avcodec.h>\n#include <libavutil/mem.h>:' \
		VideoPlayerPipHd.c || die

	# libav10 support
	sed -i \
		-e "s:avcodec_alloc_frame:av_frame_alloc:" \
		VideoPlayerPipHd.c
}

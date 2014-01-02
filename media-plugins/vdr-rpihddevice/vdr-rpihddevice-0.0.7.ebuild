# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit vdr-plugin-2

DESCRIPTION="VDR Plugin: Output Device for Raspberry Pi"
HOMEPAGE="http://www.reufer.ch/vdr/" # may be later on vdr-developer.org
SRC_URI="http://www.reufer.ch/vdr/${P}.tgz"

KEYWORDS="~arm"
SLOT="0"
LICENSE="GPL-2"
IUSE=""

DEPEND=">=media-video/vdr-2.0.0
		=media-libs/raspberrypi-userland-0*
		<=media-video/ffmpeg-1.0.8"
#		virtual/ffmpeg fixing later, sources needs exactly <=ffmpeg-1.0.8, libav not implemented yet
RDEPEND="${DEPEND}"

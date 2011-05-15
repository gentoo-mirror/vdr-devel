# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

DESCRIPTION="Firmware for the Technotrend S2-6400 DVB Card"
HOMEPAGE="http://www.aregel.de/"
SRC_URI="http://www.aregel.de/file_download/5/dvb-ttpremium-st7109-01_v0_2_9.zip
		http://www.aregel.de/file_download/2/dvb-ttpremium-fpga-01_v1_02.zip
		http://www.aregel.de/file_download/3/dvb-ttpremium-loader-01_v1_03.zip"

LICENSE="as-is"

SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="media-tv/tt-s2-6400-firmware"
RDEPEND="${DEPEND}"

S=${WORKDIR}


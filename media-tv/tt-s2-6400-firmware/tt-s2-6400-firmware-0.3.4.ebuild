# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

DESCRIPTION="Firmware for the Technotrend S2-6400 DVB Card"
HOMEPAGE="http://www.aregel.de/"
SRC_URI="http://www.aregel.de/file_download/9/dvb-ttpremium-st7109-01_v0_3_4.zip
		http://www.aregel.de/file_download/10/dvb-ttpremium-fpga-01_v1_09.zip
		http://www.aregel.de/file_download/7/dvb-ttpremium-loader-01_v1_03.zip"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="!media-tv/S2-6400-firmware
		app-arch/unzip"
RDEPEND="${DEPEND}"

S=${WORKDIR}

src_install() {
	insinto /lib/firmware
	doins dvb-ttpremium-fpga-01.fw dvb-ttpremium-loader-01.fw dvb-ttpremium-st7109-01.fw
}
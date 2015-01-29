# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: Exp $

EAPI="5"

inherit mercurial linux-info linux-mod

DESCRIPTION="Video 4 Linux experimental driver"
HOMEPAGE="http://linuxtv.org/hg/~endriss/media_build_experimental"

EHG_REVISION="1969cdc5388b"
EHG_REVISION_DATE="20150129"
EHG_REPO_URI="http://linuxtv.org/hg/~endriss/media_build_experimental"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="!media-tv/v4l-dvb-saa716x"
RDEPEND="${DEPEND}"

S="${WORKDIR}/media_build_experimental-${EHG_REVISION}"

CONFIG_CHECK="!MEDIA_SUPPORT"

src_prepare() {
	einfo "fetch additional sources from linuxtv.org"
	emake download
	einfo "fetch additional driver for TT DVB S2-6400"
	emake untar

	#fix Makefile for multicore support
	sed -e "s:make -C firmware:\$(MAKE) -C firmware:"\
		-i "${S}"/v4l/Makefile
}

src_compile() {
	set_arch_to_kernel # .. or it'll look for /arch/amd64/Makefile
	emake
}

src_install() {
	dodir /lib/modules/"${KV_FULL}"

	emake install DESTDIR="${D}"

	# rm some files to prevent for override existing files or Access Violation
	# need testing, fixing, later...
	rm "${D}"/lib/modules/"${KV_FULL}"/modules.*
}

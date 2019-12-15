# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

inherit eutils

RESTRICT="strip"

DESCRIPTION="eHD PCI card: tools svn r${PV}"
HOMEPAGE="http://www.reel-multimedia.com"
SRC_URI="http://vdr.websitec.de/download/${PN}/${P}.tgz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="=media-video/reelbox-ehd-headers-${PV}-r0"
RDEPEND="${DEPEND}"

S=${WORKDIR}/hdshm3

src_prepare() {

	sed -i "${WORKDIR}"/hdfbshot/Makefile \
		-e "s:^include:#include:" \
		-e "s:(CC):(CC) ${CFLAGS}:"

	sed -i "${S}"/x86/hdtsplay/Makefile -e "s:LDFLAGS   =:LDFLAGS   ?=:"

	sed -i Makefile \
		-e "s:gcc-3.3:gcc:g" \
		-e "s:g++-3.3:g++:g" \
		-e "s:x86/driver::"

	einfo "Changing framebuffer device to /dev/fb_reel"
	find . -type f -exec sed -i	"s:/dev/fb0:/dev/fb_reel:g" {} \;
}

src_compile() {

	emake clean || die "emake clean failed"
	emake x86 || die "emake x86 failed"
	cd x86/hdtsplay
	emake || die "emake hdtsplay failed"
#	cd "${WORKDIR}"/hdfbshot
#	emake || die "emake hdfbshot failed"
}

src_install() {

	dobin "${S}"/x86/hdboot/hdboot
	dobin "${S}"/x86/hdctrld/hdctrld
	dobin "${S}"/x86/shmnetd/shmnetd
#	dobin "${WORKDIR}"/hdfbshot/hdfbshot
	dobin "${S}"/x86/hdfbctl/hdfbctl
	dobin "${S}"/x86/hdtsplay/hdtsplay
}

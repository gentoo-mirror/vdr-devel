# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

RESTRICT="mirror"

inherit linux-mod eutils multilib

DESCRIPTION="eHD PCI card; driver svn r${PV}"
HOMEPAGE="http://www.reel-multimedia.com"
SRC_URI="http://vdr.websitec.de/download/${PN}/${P}.tgz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}
		>=sys-fs/udev-141"

S=${WORKDIR}/hdshm3

MODULE_NAMES="hdshm(misc:${S}/x86/driver)"
BUILD_TARGETS="all"

pkg_setup() {

	if ! kernel_is 2 6; then
		die "This package works only with 2.6 kernel!"
	fi

	linux-mod_pkg_setup

	BUILD_PARAMS="INCLUDE=${KV_DIR}"
}

src_prepare() {

	if kernel_is ge 2 6 33 ; then
		sed -i "${S}"/src/driver/hdshm.c \
			-e "s:linux/autoconf.h:generated/autoconf.h:"
	fi

	einfo "Changing framebuffer device to /dev/fb_reel"
	find . -type f -exec sed -i "s:/dev/fb0:/dev/fb_reel:g" {} \;
}

src_install() {
	linux-mod_src_install

	insinto $(get_libdir)/udev/rules.d
	doins "${FILESDIR}"/45-reelbox.rules

	insinto /etc/modprobe.d
	doins "${FILESDIR}"/hdshm.conf
}

pkg_postinst() {
	linux-mod_pkg_postinst

	OLD_PARAM=$( cat /etc/make.conf | grep EHD_FRAMEBUFFER )

	if [ -n "${OLD_PARAM}" ]; then
		echo
		elog "The EHD_FRAMEBUFFER= parameter in /etc/make.conf is deprecated."
		elog "You can safely remove it."
	fi
		echo
		elog "Use for your scripts, progs, ..."
		elog "the device /dev/fb_reel"
		echo
}

# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

MY_PV=${PV/*_pre/}
MY_P=${PN}-${MY_PV}

inherit vdr-plugin eutils

DESCRIPTION="Video Disk Recorder Client/Server streaming plugin"
HOMEPAGE="http://www.magoa.net/linux/"
SRC_URI="http://vdr.websitec.de/download/${PN}/${MY_P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+client +server"

DEPEND=">=media-video/vdr-1.7.5
	!media-plugins/vdr-streamdev-client
	!media-plugins/vdr-streamdev-server"
RDEPEND="${DEPEND}"

S=${WORKDIR}/streamdev-${MY_PV}

EXTERNREMUX_PATH=/usr/share/vdr/streamdev/externremux.sh

pkg_setup() {
	vdr-plugin_pkg_setup

	if ! use client && ! use server; then
		die "no plugins selected, change useflags and enable at least client or server!"
	fi
}

src_prepare() {
	vdr-plugin_src_prepare

	# Moving externremux.sh out of /root
	sed -i remux/extern.c \
		-e "s#/root/externremux.sh#${EXTERNREMUX_PATH}#"

	# make subdir libdvbmpeg respect CXXFLAGS
	sed -i Makefile \
		-e '/CXXFLAGS.*+=/s:^:#:'
	sed -i libdvbmpeg/Makefile \
		-e 's:CFLAGS =  -g -Wall -O2:CFLAGS = $(CXXFLAGS) :'

	for flag in client server; do
		if ! use ${flag}; then
			sed -i Makefile \
				-e '/^all:/s/libvdr-$(PLUGIN)-'${flag}'.so//'
		fi
	done

	fix_vdr_libsi_include server/livestreamer.c
}

src_install() {
	vdr-plugin_src_install

	cd "${S}"
	if use server; then
		insinto /etc/vdr/plugins/streamdev
		doins streamdev/streamdevhosts.conf
		chown vdr:vdr "${D}"/etc/vdr -R
	fi
}

pkg_postinst() {
	vdr-plugin_pkg_postinst

	elog "If you want to use the externremux-feature, then put"
	elog "your custom script as ${EXTERNREMUX_PATH}."

	if [[ -e "${ROOT}"/etc/vdr/plugins/streamdevhosts.conf ]]; then
		einfo "move config file to new config DIR ${ROOT}/etc/vdr/plugins/streamdev/"
		mv "${ROOT}"/etc/vdr/plugins/streamdevhosts.conf "${ROOT}"/etc/vdr/plugins/streamdev/streamdevhosts.conf
	fi
}

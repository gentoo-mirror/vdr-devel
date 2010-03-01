# Copyright 1999-2010 Warez Incorporated
# Distributed under the terms of the GNU General Public License v2
# $Header: $

RESTRICT="mirror strip"

inherit vdr-plugin mercurial

: ${EHG_REPO_URI:=http://85.17.209.13:6100/sc}

DESCRIPTION="VDR plugin: softcam HG-Version"
HOMEPAGE="http://vdr.bluox.org"
SRC_URI=""

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND=">=media-video/vdr-1.4.6
		dev-libs/openssl"

S="${WORKDIR}/sc"

src_unpack() {
	mercurial_src_unpack
	vdr-plugin_src_unpack all_but_unpack

	fix_vdr_libsi_include systems/viaccess/tps.c
	fix_vdr_libsi_include systems/viaccess/viaccess.c

	cd "${S}"

	sed -i Makefile.system \
		-e "s:^LIBDIR.*$:LIBDIR = ${S}:"

	sed -i Makefile \
		-e "s:/include/vdr/config.h:/config.h:" \
		-e "s:-march=\$(CPUOPT)::" \
		-e "s:\$(CSAFLAGS):\$(CXXFLAGS):" \
		-e "s:ci.c:ci.h:" \
		-e "s:include/vdr/i18n.h:i18n.h:"
}

src_install() {
	vdr-plugin_src_install

	insinto usr/$(get_libdir)/vdr/plugins
	doins "${S}"/libsc*

	diropts -gvdr -ovdr
	keepdir /etc/vdr/plugins/sc
}

pkg_postinst() {
	vdr-plugin_pkg_postinst

	elog "This software might be illegal in some countries or violate"
	elog "rules of your DVB provider"
	elog "Please respect these rules."
	echo
	elog "We do not offer support of any kind"
	elog "Asking for keys or for installation help will be is ignored by gentoo developers!"
	echo
}

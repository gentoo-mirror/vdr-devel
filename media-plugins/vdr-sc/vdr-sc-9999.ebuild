# Copyright 1999-2012 Warez Incorporated
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit eutils vdr-plugin mercurial

: ${EHG_REPO_URI:=http://85.17.209.13:6100/sc}

DESCRIPTION="VDR plugin: softcam HG-Version"
HOMEPAGE="http://207.44.152.197/vdr2.htm"
SRC_URI=""

SLOT="0"
LICENSE="GPL-2"
KEYWORDS=""
IUSE=""

DEPEND=">=media-video/vdr-1.4.6
		dev-libs/openssl"
RDEPEND="${DEPEND}"

S="${WORKDIR}/sc"

MAKEOPTS="-j1" # workaround for now

src_prepare() {
	vdr-plugin_src_prepare

	fix_vdr_libsi_include systems/viaccess/tps.c
	fix_vdr_libsi_include systems/viaccess/viaccess.c

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

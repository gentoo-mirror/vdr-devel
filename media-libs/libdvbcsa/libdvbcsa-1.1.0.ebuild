# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: Exp $

EAPI=5

inherit eutils

DESCRIPTION="Free implementation of the DVB Common Scrambling Algorithm - DVB/CSA"
HOMEPAGE="http://www.videolan.org/developers/${PN}.html"
SRC_URI="http://download.videolan.org/pub/videolan/${PN}/${PV}/${P}.tar.gz"

KEYWORDS="~amd64 ~x86"
LICENSE="GPL-2"
SLOT="0"
IUSE="debug cpu_flags_x86_mmx cpu_flags_x86_sse2 +static-libs"

DEPEND=""

DOCS=( AUTHORS ChangeLog INSTALL NEWS README )

src_prepare() {
	epatch_user
}

src_configure() {
	econf \
		$(use_enable ppc altivec) \
		$(use_enable debug) \
		$(use_enable cpu_flags_x86_mmx mmx) \
		$(use_enable cpu_flags_x86_sse2 sse2) \
		$(use_enable static-libs static) \
		$(use_enable x86 uint32) \
		$(use_enable amd64 uint64) \
		--enable-shared
}

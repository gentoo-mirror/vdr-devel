# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit flag-o-matic

GIT_VERSION="e9345b965492b4b2c2e6cf9795d43ad15c8758cc"
#git commit 2016/08/12

DESCRIPTION="minisatip, a SAT>IP server using local DVB-S2, DVB-C, DVB-T or ATSC cards"
HOMEPAGE="https://minisatip.org/"
SRC_URI="https://github.com/catalinii/minisatip/archive/${GIT_VERSION}.tar.gz"

LICENSE="GPL-2"
SLOT="0"

KEYWORDS="~amd64 ~x86"

IUSE="-dvbcsa"

DEPEND="media-libs/libdvbcsa"
# libdvbcsa default installed without use-flag handling,
# as it fails on compile without it, need fixing by upstream

S="${WORKDIR}/minisatip-${GIT_VERSION}"

pkg_setup() {
	append-flags -lpthread -fPIC -lrt
}

src_configure() {
	local config_dvbcsa=""
	! use  dvbcsa && config_dvbcsa="--disable-dvbcsa"

	econf \
		--prefix=/usr/bin \
		${config_dvbcsa} \
		|| die "configure failed"
}

src_install() {
	dobin minisatip

	newinitd "${FILESDIR}"/minisatip.init minisatip
	newconfd "${FILESDIR}"/minisatip.conf minisatip

	local HTML_DOCS="html/*"

	einstalldocs
}

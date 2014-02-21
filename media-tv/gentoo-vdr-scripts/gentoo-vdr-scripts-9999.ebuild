# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-tv/gentoo-vdr-scripts/gentoo-vdr-scripts-9999.ebuild,v 1.8 2006/10/13 10:43:30 zzam Exp $

EAPI=5

inherit eutils git-2 user

EGIT_REPO_URI="git://git.overlays.gentoo.org/proj/gentoo-vdr-scripts.git"

DESCRIPTION="Scripts necessary for use of vdr as a set-top-box"
HOMEPAGE="http://www.gentoo.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm ~ppc ~x86"
IUSE="nvram"

RDEPEND="nvram? ( sys-power/nvram-wakeup )
	app-admin/sudo
	sys-process/wait_on_pid"

VDR_HOME=/var/vdr

pkg_setup() {
	enewgroup vdr

	# Add user vdr to these groups:
	#   video - accessing dvb-devices
	#   audio - playing sound when using software-devices
	#   cdrom - playing dvds/audio-cds ...
	enewuser vdr -1 /bin/bash "${VDR_HOME}" vdr,video,audio,cdrom
}

# disabled for testing
#src_prepare() {
#	use systemd && sed -i "${S}"/Makefile -e "s:VDRSYSTEMD ?= 0:VDRSYSTEMD = 1:"
#}

src_install() {
	emake -s install DESTDIR="${D}" || die "make install failed"
	nonfatal dodoc README TODO ChangeLog

	# create necessary directories
	diropts -ovdr -gvdr
	keepdir "${VDR_HOME}"

	local kd
	for kd in shutdown-data merged-config-files dvd-images tmp; do
		keepdir "${VDR_HOME}/${kd}"
	done
}
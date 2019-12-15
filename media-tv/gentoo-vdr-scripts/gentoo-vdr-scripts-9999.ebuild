# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit git-r3 user

EGIT_REPO_URI="git://git.gentoo.org/proj/gentoo-vdr-scripts.git"

DESCRIPTION="Scripts necessary for use of vdr as a set-top-box"
HOMEPAGE="https://gitweb.gentoo.org/proj/gentoo-vdr-scripts.git/about/"
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

src_install() {
	local DOCS=( README* TODO ChangeLog )

	default

	# create necessary directories
	diropts -ovdr -gvdr
	keepdir "${VDR_HOME}"

	local kd
	for kd in shutdown-data merged-config-files dvd-images; do
		keepdir "${VDR_HOME}/${kd}"
	done
}

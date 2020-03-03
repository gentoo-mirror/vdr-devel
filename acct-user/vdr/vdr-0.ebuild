# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit acct-user

DESCRIPTION="VDR (VideoDiskRecorder) user"

IUSE="graphlcd remote serial systemd"

ACCT_USER_ID=452
ACCT_USER_HOME=/var/lib/vdr
ACCT_USER_HOME_OWNER=vdr:vdr
ACCT_USER_HOME_PERMS=0775
ACCT_USER_GROUPS=( audio cdrom vdr video )

acct-user_add_deps

DEPEND+=" acct-group/vdr "
RDEPEND+=" acct-group/vdr "

pkg_setup() {
	# media-plugins/vdr-graphlcd
	use graphlcd && ACCT_USER_GROUPS+=( lp usb )

	# media-plugins/vdr-remote, _only_ on systemd crap
	if use systemd; then
		use remote && ACCT_USER_GROUPS+=( input )
	else
		ewarn "\nuse-flag remote only needed on systemd\n"
	fi

	# media-plugins/vdr-serial
	use serial && ACCT_USER_GROUPS+=( uucp )
}

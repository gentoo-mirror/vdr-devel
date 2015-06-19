# $Header: /var/cvsroot/gentoo-x86/media-plugins/vdr-graphtft/files/rc-addon.sh,v 1.2 2009/10/22 14:26:11 hd_brummy Exp $
#
# rc-addon-script for plugin graphtftng & graphtft-fe
#
# Joerg Bornkessel <hd_brummy@g.o>

. /etc/conf.d/vdr.graphtftng

plugin_pre_vdr_start() {

		: ${GRAPHTFTNG_DEVICE:=/dev/fb0}

		add_plugin_param "-d ${GRAPHTFTNG_DEVICE}"
}

# $Header: $
#
# rc-addon-script for plugin streamdev-server
#
# Joerg Bornkessel <hd_brummy@g.o>

plugin_pre_vdr_start() {

		: ${STREAMDEV_REMUX_SCRIPT:=/usr/share/vdr/streamdev/externremux.sh}

		add_plugin_param "-r ${STREAMDEV_REMUX_SCRIPT}"
}

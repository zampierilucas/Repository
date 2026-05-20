#!/bin/sh

set -e

INSTALL_DIR=/mnt/us/kindle_hid_passthrough
APPREG_DB=/var/local/appreg.db
APP_ID="com.lzampier.btmanager"

# ---- Stop service ----

/sbin/initctl stop hid-passthrough 2>/dev/null || true

# ---- Remove system files ----

/usr/sbin/mntroot rw

rm -f /etc/upstart/hid-passthrough.conf
rm -f /etc/udev/rules.d/99-hid-keyboard.rules
[ -f /usr/local/bin/dev_is_keyboard.sh ] && rm -f /usr/local/bin/dev_is_keyboard.sh
/usr/sbin/udevadm control --reload-rules 2>/dev/null || true

/usr/sbin/mntroot ro || true

# ---- Unregister WAF app ----

if [ -f "$APPREG_DB" ]; then
    sqlite3 "$APPREG_DB" <<EOF
DELETE FROM properties WHERE handlerId='$APP_ID';
DELETE FROM associations WHERE handlerId='$APP_ID';
DELETE FROM handlerIds WHERE handlerId='$APP_ID';
EOF
fi

# ---- Remove KOReader plugin (if installed) ----

rm -rf /mnt/us/koreader/plugins/hidpassthrough.koplugin

# ---- Remove files ----

rm -rf "$INSTALL_DIR"
rm -f /mnt/us/documents/BTManager.sh

exit 0

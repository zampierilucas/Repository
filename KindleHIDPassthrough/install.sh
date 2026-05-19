#!/bin/sh

set -e

TMPDIR=/mnt/us/KFPM-Temporary
INSTALL_DIR=/mnt/us/kindle_hid_passthrough
RELEASE_URL="https://github.com/zampierilucas/kindle-hid-passthrough/releases/latest/download"

mkdir -p "$TMPDIR"

# ---- Download and extract release ----

curl -fSL --progress-bar -o "$TMPDIR/release.tar.gz" \
    "$RELEASE_URL/kindle-hid-passthrough-armv7.tar.gz"
mkdir -p "$INSTALL_DIR"
tar -xzf "$TMPDIR/release.tar.gz" -C "$INSTALL_DIR"

# ---- Install system files (requires rw root) ----

/usr/sbin/mntroot rw

cp "$INSTALL_DIR/assets/hid-passthrough.upstart" /etc/upstart/hid-passthrough.conf
cp "$INSTALL_DIR/assets/99-hid-keyboard.rules" /etc/udev/rules.d/
/usr/sbin/udevadm control --reload-rules

/usr/sbin/mntroot ro || true

# ---- Set permissions ----

chmod +x "$INSTALL_DIR/kindle-hid-passthrough"
chmod +x "$INSTALL_DIR/illusion/BTManager.sh"
mkdir -p "$INSTALL_DIR/cache"

# ---- Install scriptlet (registers WAF app on first launch) ----

cp "$INSTALL_DIR/illusion/BTManager.sh" /mnt/us/documents/BTManager.sh
chmod +x /mnt/us/documents/BTManager.sh

# ---- Install KOReader plugin (if KOReader is installed) ----

if [ -d /mnt/us/koreader/plugins/ ] && [ -d "$INSTALL_DIR/koreader-plugin/hidpassthrough.koplugin" ]; then
    mkdir -p /mnt/us/koreader/plugins/hidpassthrough.koplugin
    cp -r "$INSTALL_DIR/koreader-plugin/hidpassthrough.koplugin/." \
        /mnt/us/koreader/plugins/hidpassthrough.koplugin/
fi

# ---- Start daemon ----

/sbin/initctl start hid-passthrough || true

# ---- Cleanup ----

rm -rf "$TMPDIR"

exit 0

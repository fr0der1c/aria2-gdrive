#!/usr/bin/env bash
rclone mount my-drive:/ /data/GoogleDrive --allow-other --allow-non-empty --vfs-cache-mode writes --daemon
nginx
aria2c --rpc-secret="$ARIA2_RPC_SECRET"

if [ "$ARIA2_RPC_TLS" = "true" ]; then
echo "Start aria2 with SSL/TLS config"
aria2c --rpc-secret="$ARIA2_RPC_SECRET"\
--rpc-certificate=/aria2.crt \
--rpc-private-key=/aria2.key \
--rpc-secure

else
echo "Start aria2 without SSL/TLS. You should be protected with SSL/TLS when you are in public net."
aria2c --rpc-secret="$ARIA2_RPC_SECRET"
fi
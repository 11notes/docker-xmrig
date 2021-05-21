#!/bin/ash
if env | grep "XMRIG_WORKERID" -q; then
    XMRIG_WORKERID="${HOSTNAME}"
fi
exec /xmrig/bin/xmrig -c /xmrig/etc/config.json --http-no-restricted --api-worker-id $XMRIG_WORKERID --http-access-token $XMRIG_HTTP_ACCESS_TOKEN
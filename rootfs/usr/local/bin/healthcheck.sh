#!/bin/ash
CURL_HTTP_CODE=$(curl --max-time 5 -s --fail -o /dev/stderr -w "%{http_code}" http://localhost:3000)
if [ $CURL_HTTP_CODE -eq 200 ] ||[ $CURL_HTTP_CODE -eq 401 ]; then
    exit 0
else
    exit 1
fi
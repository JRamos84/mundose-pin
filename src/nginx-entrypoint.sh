#!/bin/sh
rm /usr/share/nginx/html/index.html
exec nginx -g "daemon off;"
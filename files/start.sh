#!/bin/bash

LISTEN_PORT=80
LISTEN_HTTP2=
LISTEN_SSL=

# check whether we should enable SSL/TLS
if [ "$USE_SSL" = "1" ]; then

  # check other needed variables are set
  if [ ! -r "/etc/nginx/server.crt" ] || [ ! -r "/etc/nginx/server.key" ]; then
    echo "WARNiNG: Cannot find SSL_CERT and/or SSL_KEY, falling back to http" >&2
  elif [[ ! "${EXTERNAL_HTTPS_PORT}" =~ ^[0-9]+$ ]]; then
    echo "ERROR: invalid HTTPS_EXTERNAL_PORT $HTTPS_EXTERNAL_PORT" >&2
    exit 1
  else
    LISTEN_PORT=443
    LISTEN_HTTP2=http2
    LISTEN_SSL=ssl
    sed -i "s|###TLS ||g;
            s|###SSL_CERT###|${SSL_CERT}|g;
            s|###SSL_KEY###|${SSL_KEY}|g;
            s|###EXTERNAL_HTTPS_PORT###|${EXTERNAL_HTTPS_PORT}|g;
    " /etc/nginx/conf.d/default.conf

    if [ "${DHPARAMS}" = "1" ]; then
      openssl dhparam -dsaparam -out /etc/nginx/dhparams.pem 4096
      sed -i "s|###DHPARAMS ||g;
      " /etc/nginx/conf.d/default.conf
    fi
  fi
fi

if [ "$HTTP_AUTH_USER" != "" ] && [ "$HTTP_AUTH_PASS" != "" ]; then
  # generate HTTP auth file
  printf "%s:%s\n" "${HTTP_AUTH_USER}" "$(openssl passwd -apr1 "${HTTP_AUTH_PASS}")" > /etc/nginx/htpasswd
  sed -i "s|###HTTP_AUTH ||g;
  " /etc/nginx/conf.d/default.conf
fi

sed -i "s|###LISTEN_PORT###|${LISTEN_PORT}|g;
        s|###LISTEN_HTTP2###|${LISTEN_HTTP2}|g;
        s|###LISTEN_SSL###|${LISTEN_SSL}|g;
       " /etc/nginx/conf.d/default.conf

# set correct ownership for data dir
chown -R www-data:www-data /rainloop/data

mkdir -p /run/nginx
exec /usr/bin/supervisord -n -c /etc/supervisord.conf


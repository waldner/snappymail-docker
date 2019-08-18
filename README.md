# rainloop-docker

### What's this?

`Dockerfile` and compose file to run the [rainloop](https://www.rainloop.net) webmail client.

The image lives at [Docker hub](https://hub.docker.com/r/waldner/rainloop).

### Using the image

- If you cloned the github repository, skip this step. Otherwise create a file `docker-compose.yml` with the following content:

```
version: "3.3"

services:
  rainloop:
    image: waldner/rainloop:1.13.0
    container_name: rainloop
    hostname: rainloop
    volumes:
      - ${WEBMAIL_DATA}:/rainloop/data
    ports:
      - ${EXTERNAL_HTTP_PORT:-80}:80
    environment:
      - TZ=${TZ:-UTC}
      - USE_SSL=${USE_SSL:-0}
```

- Create a file named `.env` (in the same place where you put the `docker-compose.yml` file) with the following content:

```
# mandatory: where the data volume for rainloop is in the host filesystem
WEBMAIL_DATA=/path/to/rainloop/data

# optional: if you want HTTP auth, put credentials in here,
# otherwise don't define these two variables
HTTP_AUTH_USER=myuser
HTTP_AUTH_PASS=mypass

# optional: time zone (default: UTC)
TZ=Europe/Berlin

# optional: which host port will be exposed for HTTP requests (default: 80)
EXTERNAL_HTTP_PORT=8080

# optional: whether to enable ssl (default: 0)
USE_SSL=1

# mandatory if USE_SSL=1: TLS certificate and key locations in local filesystem
LOCAL_SSL_CERT=/path/to/server.crt
LOCAL_SSL_KEY=/path/to/server.key

# optional: which host port will be exposed for HTTPS requests (default: 443)
# only used if USE_SSL=1
EXTERNAL_HTTPS_PORT=8443

```

- If you want to use SSL (`USE_SSL=1`) and thus assigned values to `LOCAL_SSL_CERT` and `LOCAL_SSL_KEY` (and possibly `EXTERNAL_HTTPS_PORT`): create a `docker-compose.override.yml` in the same directory with the following content (or, if you cloned the repo, just run `cp docker-compose.override.yml.sample docker-compose.override.yml`):

```
version: "3.3"

services:
  rainloop:
    ports:
      - ${EXTERNAL_HTTPS_PORT:-443}:443
    volumes:
      - ${LOCAL_SSL_CERT}:/etc/nginx/server.crt
      - ${LOCAL_SSL_KEY}:/etc/nginx/server.key
    environment:
      EXTERNAL_HTTPS_PORT: ${EXTERNAL_HTTPS_PORT:-443}
```

- Run the image with `docker-compose up -d`

### Getting started

If you're starting from scratch, make sure the the directory used for `$WEBMAIL_DATA` has the necessary permissions for rainloop's web user; in practice, it means it has to be owned by user and group **82**, otherwise you'll get permission errors:

```
# chown -R 82:82 /path/to/rainloop/data
```

As explained in [the docs](https://www.rainloop.net/docs/configuration/), to perform the initial configuration you have to go to `http[s]://your.domain.tld:yourport/?admin`. The initial username/password (*which you should change immediately*) is `admin/12345`.

Many settings can be configured from the administration interface; for some others you'll have to edit the configuration file (`application.ini`, located inside the data directory) by hand.

In particular, if you need to use **cram-md5** authentication with some IMAP or SMTP server, see [this page in the wiki](https://github.com/RainLoop/rainloop-webmail/wiki/How-to-enable-CRAM-MD5-for-IMAP-and-or-SMTP).

### Miscellaneous

- When using SSL, all incoming requests to `$HTTP_EXTERNAL_PORT` are redirected to the HTTPS version of the page on port `$HTTPS_EXTERNAL_PORT`.
- All daemons log to stdout, so you can use `docker logs` to see the messages.
- Internally, the container runs [nginx](http://nginx.org/) and [php-fpm](https://www.php.net/), controlled by [supervisord](http://supervisord.org/).

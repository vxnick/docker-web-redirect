# Docker-Web-Redirect #

This Docker container listens on port 80 and redirects all web traffic permanently to the given target domain/URL.

Based on [MorbZ/docker-web-redirect](https://github.com/MorbZ/docker-web-redirect).

## Features ##
- Lightweight: Uses only ~2 MB RAM on Linux
- Keeps the URL path and GET parameters
- Permanent redirect (HTTP 301)
- Multiple redirects (this fork) with `REDIRECTS='olddomain.com=newdomain.com,olddomain2.com=newdomain2.com'`
- Simple log format to see what traffic the old domains are getting (this fork)

## Usage ##
### Docker run ###
The target domain/URL(s) are set by the `REDIRECTS` environment variable.
Possible redirect targets include domains (`mydomain.net`), paths (`mydomain.net/my_page`) or specific protocols (`https://mydomain.net/my_page`).

**Example:** `$ docker run --rm -d -e REDIRECTS='mydomain.net=example.com,mydomain2.net=google.com' -p 80:80 vxnick/docker-web-redirect`

### Paths are retained ###
The URL path and GET parameters are retained. That means that a request to `http://myolddomain.net/index.php?page=2` will be redirected to `http://mydomain.net/index.php?page=2` when `REDIRECTS='myolddomin.net=mydomain.net'` is set.

### Permanent redirects ###
Redirects are permanent (HTTP status code 301). That means browsers will cache the redirect and will go directly to the new site on further requests. Also search engines will recognize the new domain and change their URLs. This means this image is not suitable for temporary redirects e.g. for site maintenance.

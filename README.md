# WireGuard Easy

This project is an fork with updates of a simpler, earlier version of the application.

It is designed to be used with a reverse proxy for improved security. It is highly recommended to restrict access to the admin interface using a reverse proxy. The provided `docker-compose` example includes a complete setup with password protection. Using Traefik for authentication is advised, as it is more robust and thoroughly tested.

Key updates in this fork include modifications to the `Dockerfile` to update all package versions, notably upgrading to Node.js 23.

[![Build & Publish Docker Image to Docker Hub](https://github.com/wg-easy/wg-easy/actions/workflows/deploy.yml/badge.svg?branch=production)](https://github.com/wg-easy/wg-easy/actions/workflows/deploy.yml)
[![Lint](https://github.com/wg-easy/wg-easy/actions/workflows/lint.yml/badge.svg?branch=master)](https://github.com/wg-easy/wg-easy/actions/workflows/lint.yml)
![Docker](https://img.shields.io/docker/pulls/weejewel/wg-easy.svg)
[![Sponsor](https://img.shields.io/github/sponsors/weejewel)](https://github.com/sponsors/WeeJeWel)
![GitHub Stars](https://img.shields.io/github/stars/wg-easy/wg-easy)

You have found the easiest way to install & manage WireGuard on any Linux host!

<p align="center">
  <img src="./assets/screenshot.png" width="802" />
</p>

## Features
* All-in-one: WireGuard + Web UI.
* Easy installation, simple to use.
* List, create, edit, delete, enable & disable clients.
* Show a client's QR code.
* Download a client's configuration file.
* Statistics for which clients are connected.
* Tx/Rx charts for each connected client.
* Gravatar support.
* Automatic Light / Dark Mode
* Multilanguage Support
* UI_TRAFFIC_STATS (default off)

## Requirements

* A host with a kernel that supports WireGuard (all modern kernels).
* A host with Docker installed.

## Versions

We provide more then 1 docker image to get, this will help you decide which one is best for you. <br>
For **stable** versions instead of nightly or development please read **README** from the **production** branch!

| tag | Branch | Example | Description |
| - | - | - | - |
| `latest` | production | `ghcr.io/wg-easy/wg-easy:latest` or `ghcr.io/wg-easy/wg-easy` | stable as possbile get bug fixes quickly when needed, deployed against `production`. |
| `13` | production | `ghcr.io/wg-easy/wg-easy:13` | same as latest, stick to a version tag. |
| `nightly` | master | `ghcr.io/wg-easy/wg-easy:nightly` | mostly unstable gets frequent package and code updates, deployed against `master`. |
| `development` | pull requests | `ghcr.io/wg-easy/wg-easy:development` | used for development, testing code from PRs before landing into `master`. |

## Installation

### 1. Install Docker

If you haven't installed Docker yet, install it by running:

```bash
curl -sSL https://get.docker.com | sh
sudo usermod -aG docker $(whoami)
exit
```

And log in again.

### 2. Run WireGuard Easy

To automatically install & run wg-easy, simply run:

```
services:
  wg-easy:
    image: ghcr.io/mladia/wg-easy:latest
    restart: always
    environment:
      # Change Language:
      # (Supports: en, ua, ru, tr, no, pl, fr, de, ca, es, ko, vi, nl, is, pt, chs, cht, it, th, hi)
      - LANG=de
      # ⚠️ Required:
      # Change this to your host's public address
      - WG_HOST=raspberrypi.local
      # Optional:
      # Either this or use the traefik password midleware
      # - PASSWORD_HASH=$$2y$$10$$hBCoykrB95WSzuV4fafBzOHWKu9sbyVa34GJr8VV5R/pIelfEMYyG (needs double $$, hash of 'foobar123'; see "How_to_generate_an_bcrypt_hash.md" for generate the hash)
      # - PORT=51821
      # - WG_PORT=51820
      # - WG_CONFIG_PORT=92820
      # - WG_DEFAULT_ADDRESS=10.8.0.x
      # - WG_DEFAULT_DNS=1.1.1.1
      # - WG_MTU=1420
      # - WG_ALLOWED_IPS=192.168.15.0/24, 10.0.1.0/24
      # - WG_PERSISTENT_KEEPALIVE=25
      # - WG_PRE_UP=echo "Pre Up" > /etc/wireguard/pre-up.txt
      # - WG_POST_UP=echo "Post Up" > /etc/wireguard/post-up.txt
      # - WG_PRE_DOWN=echo "Pre Down" > /etc/wireguard/pre-down.txt
      # - WG_POST_DOWN=echo "Post Down" > /etc/wireguard/post-down.txt
      # - UI_TRAFFIC_STATS=true
      # - UI_CHART_TYPE=0 # (0 Charts disabled, 1 # Line chart, 2 # Area chart, 3 # Bar chart)
    container_name: wg-easy
    ports:
      - "51820:51820/udp"
      # - "51821:51821/tcp"  Not needed, as access is done through the traefik domain name
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    volumes:
      - ./wireguard-prod:/etc/wireguard
      - /lib/modules:/lib/modules:ro
    sysctls:
      - net.ipv4.ip_forward=1
      - net.ipv4.conf.all.src_valid_mark=1
      - net.ipv6.conf.all.disable_ipv6=0
      - net.ipv6.conf.all.forwarding=1
      - net.ipv6.conf.default.forwarding=1
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.wg-easy.entrypoints=websecure"
      - "traefik.http.routers.wg-easy.tls=true"
      - "traefik.http.services.wg-easy.loadbalancer.server.port=51821"
      - "traefik.http.routers.wg-easy.middlewares=wg-easy-auth@docker"
      # From https://doc.traefik.io/traefik/middlewares/http/basicauth/#users
      # Declaring the user list
      #
      # Note: when used in docker-compose.yml all dollar signs in the hash need to be doubled for escaping.
      # To create a user:password pair, the following command can be used:
      # echo $(htpasswd -nb user password) | sed -e s/\\$/\\$\\$/g
      #
      # Also note that dollar signs should NOT be doubled when they not evaluated (e.g. Ansible docker_container module).
      - "traefik.http.middlewares.wg-easy-auth.basicauth.users=user:$$apr1$$aliwk2kE$$12hsjxikdld2hf91l23h7/"
      - "traefik.http.routers.wg-easy.rule=Host(`wg-easy.local`)"
      - "traefik.http.routers.wg-easy.tls.domains[0].main=wg-easy.local"
      - "traefik.http.routers.wg-easy.tls.domains[0].sans=localhost"

  traefik:
    image: traefik:latest
    container_name: traefik
    restart: always
    command:
      - --providers.docker
      - --providers.docker.exposedbydefault=false
      - --entrypoints.web.address=:80
      - --entrypoints.web.http.redirections.entryPoint.to=websecure
      - --entrypoints.web.http.redirections.entryPoint.scheme=https
      - --entrypoints.websecure.address=:443
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro 
```

> 💡 Replace `YOUR_SERVER_IP` with your WAN IP, or a Dynamic DNS hostname.
>
> 💡 Replace `YOUR_ADMIN_PASSWORD_HASH` with a bcrypt password hash to log in on the Web UI. See [How_to_generate_an_bcrypt_hash.md](./How_to_generate_an_bcrypt_hash.md) for know how generate the hash.

The Web UI will now be available on `http://0.0.0.0:51821`.

> 💡 Your configuration files will be saved in `~/.wg-easy`

WireGuard Easy can be launched with Docker Compose as well - just download
[`docker-compose.yml`](docker-compose.yml), make necessary adjustments and
execute `docker compose up --detach`.

### 3. Sponsor

Are you enjoying this project? [Buy Emile a beer!](https://github.com/sponsors/WeeJeWel) 🍻

## Options

These options can be configured by setting environment variables using `-e KEY="VALUE"` in the `docker run` command.

| Env | Default | Example | Description                                                                                                                                          |
| - | - | - |------------------------------------------------------------------------------------------------------------------------------------------------------|
| `PORT` | `51821` | `6789` | TCP port for Web UI.                                                                                                                                 |
| `WEBUI_HOST` | `0.0.0.0` | `localhost` | IP address web UI binds to.                                                                                                                          |
| `PASSWORD_HASH` | - | `$2y$05$Ci...` | When set, requires a password when logging in to the Web UI. See [How to generate an bcrypt hash.md]("https://github.com/wg-easy/wg-easy/blob/master/How_to_generate_an_bcrypt_hash.md") for know how generate the hash. |
| `WG_HOST` | - | `vpn.myserver.com` | The public hostname of your VPN server.                                                                                                              |
| `WG_DEVICE` | `eth0` | `ens6f0` | Ethernet device the wireguard traffic should be forwarded through.                                                                                   |
| `WG_PORT` | `51820` | `12345` | The public UDP port of your VPN server. WireGuard will listen on that (othwise default) inside the Docker container.                                 |
| `WG_CONFIG_PORT`| `51820` | `12345` | The UDP port used on [Home Assistant Plugin](https://github.com/adriy-be/homeassistant-addons-jdeath/tree/main/wgeasy)                               
| `WG_MTU` | `null` | `1420` | The MTU the clients will use. Server uses default WG MTU.                                                                                            |
| `WG_PERSISTENT_KEEPALIVE` | `0` | `25` | Value in seconds to keep the "connection" open. If this value is 0, then connections won't be kept alive.                                            |
| `WG_DEFAULT_ADDRESS` | `10.8.0.x` | `10.6.0.x` | Clients IP address range.                                                                                                                            |
| `WG_DEFAULT_DNS` | `1.1.1.1` | `8.8.8.8, 8.8.4.4` | DNS server clients will use. If set to blank value, clients will not use any DNS.                                                                    |
| `WG_ALLOWED_IPS` | `0.0.0.0/0, ::/0` | `192.168.15.0/24, 10.0.1.0/24` | Allowed IPs clients will use.                                                                                                                        |
| `WG_PRE_UP` | `...` | - | See [config.js](https://github.com/wg-easy/wg-easy/blob/master/src/config.js#L19) for the default value.                                             |
| `WG_POST_UP` | `...` | `iptables ...` | See [config.js](https://github.com/wg-easy/wg-easy/blob/master/src/config.js#L20) for the default value.                                             |
| `WG_PRE_DOWN` | `...` | - | See [config.js](https://github.com/wg-easy/wg-easy/blob/master/src/config.js#L27) for the default value.                                             |
| `WG_POST_DOWN` | `...` | `iptables ...` | See [config.js](https://github.com/wg-easy/wg-easy/blob/master/src/config.js#L28) for the default value.                                             |
| `LANG` | `en` | `de` | Web UI language (Supports: en, ua, ru, tr, no, pl, fr, de, ca, es, ko, vi, nl, is, pt, chs, cht, it, th, hi).                                        |
| `UI_TRAFFIC_STATS` | `false` | `true` | Enable detailed RX / TX client stats in Web UI                                                                                                       |
| `UI_CHART_TYPE` | `0` | `1` | UI_CHART_TYPE=0 # Charts disabled, UI_CHART_TYPE=1 # Line chart, UI_CHART_TYPE=2 # Area chart, UI_CHART_TYPE=3 # Bar chart                           |

> If you change `WG_PORT`, make sure to also change the exposed port.

## Updating

To update to the latest version, simply run:

```bash
docker stop wg-easy
docker rm wg-easy
docker pull ghcr.io/wg-easy/wg-easy
```

And then run the `docker run -d \ ...` command above again.

With Docker Compose WireGuard Easy can be updated with a single command:
`docker compose up --detach --pull always` (if an image tag is specified in the
Compose file and it is not `latest`, make sure that it is changed to the desired
one; by default it is omitted and
[defaults to `latest`](https://docs.docker.com/engine/reference/run/#image-references)). \
The WireGuared Easy container will be automatically recreated if a newer image
was pulled.

## Common Use Cases

* [Using WireGuard-Easy with Pi-Hole](https://github.com/wg-easy/wg-easy/wiki/Using-WireGuard-Easy-with-Pi-Hole)
* [Using WireGuard-Easy with nginx/SSL](https://github.com/wg-easy/wg-easy/wiki/Using-WireGuard-Easy-with-nginx-SSL)

For less common or specific edge-case scenarios, please refer to the detailed information provided in the [Wiki](https://github.com/wg-easy/wg-easy/wiki).

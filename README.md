# chausse.dev

The goal of this repos is to provide a simple solution for hosting all my
bits and bobs with a portable docker configuration.

Previously, everything was run bare-metal on a debian server, now I would
like to have everything containerized to avoid the pain of manually setting
up cronjobs, https certificates, dns entries everytime I want to migrate my
server.

To avoid building up a huge monolithic docker-compose file within this repo,
each project has it's own `docker-compose.yml` file with the root
docker-compose using the `extend` directive to orchestrate everything using
traefik.

## Site

A static portfolio site built with hugo and hosted using nginx. Only the `pub`
directory is served but the remainder is still tracked via git to easily
migrate the site.

## Dyndns

Dynamic dns container for cloudflare that ensures the ip address tracked
by cloudflare remains the correct one if the server migrates or the static-IP
changes for some ungodly reason.

## Git

A simple [soft-serve][1] instance making it easy to manage git
repositories over ssh without relying on github or going through the hassle of
configuring a full webpage with gitea.

## Uptime

A single pge meant to track the current status of my servarr/jellyfin
stack located on a separate server.

## Vault

Simple vaultwarden instance to host my passwords.

## Bots

While bots for discord don't necessarily need an http endpoint, having control
over them from this monorepo is quite practical.


[1]: https://github.com/charmbracelet/soft-serve


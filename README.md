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


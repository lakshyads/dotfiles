---
tag:
  - type/cheatsheet
  - topic/containers
related:
  - "[[homebrew-cheatsheet]]"
---

# Docker Cheat Sheet

A reference for Docker Desktop on macOS. Covers daily container/image commands, Compose workflows, and the troubleshooting you'll actually need.

Installed via Homebrew Cask (`docker-desktop`) — see [`docs/inventory.md`](inventory.md). First launch requires a one-time manual step; see [`README.md` — Launch Docker Desktop Once](../README.md#4-launch-docker-desktop-once).

Official docs: <https://docs.docker.com>

---

## Table of Contents

- [Checking Things Are Working](#checking-things-are-working)
- [Images](#images)
- [Containers](#containers)
- [Logs & Exec](#logs--exec)
- [Volumes](#volumes)
- [Networks](#networks)
- [Docker Compose](#docker-compose)
- [Dockerfile Basics](#dockerfile-basics)
- [Cleaning Up Disk Space](#cleaning-up-disk-space)
- [Common Pitfalls](#common-pitfalls)

---

## Checking Things Are Working

```bash
docker --version
docker compose version
docker info                 # daemon status, resource limits
docker context ls           # confirm you're pointed at Docker Desktop's context
docker desktop status       # is the Desktop engine actually up? (separate from the app window)
```

If `docker` commands hang or refuse to connect, Docker Desktop isn't running — open it from Spotlight or `open -a Docker`. If the app window looks fine but the CLI still can't connect, see [Docker Desktop window looks fine, but CLI still can't connect to the socket](#docker-desktop-window-looks-fine-but-cli-still-cant-connect-to-the-socket).

---

## Images

```bash
# Search / pull
docker search postgres
docker pull postgres:17
docker pull redis:7-alpine

# List local images
docker images
docker image ls --filter "dangling=true"     # untagged/orphaned layers

# Inspect
docker inspect postgres:17
docker history postgres:17                    # layer-by-layer build steps

# Build from a Dockerfile in the current directory
docker build -t myapp:latest .
docker build -t myapp:latest -f Dockerfile.dev .

# Tag and push
docker tag myapp:latest username/myapp:latest
docker push username/myapp:latest

# Remove
docker rmi postgres:17
docker image prune                            # remove dangling images
```

---

## Containers

```bash
# Run
docker run -d --name mypg -e POSTGRES_PASSWORD=secret -p 5432:5432 postgres:17
docker run -it --rm ubuntu bash               # interactive, auto-removed on exit
docker run -d --restart unless-stopped nginx  # survive daemon restarts

# List
docker ps                                     # running
docker ps -a                                  # running + stopped

# Lifecycle
docker start mypg
docker stop mypg
docker restart mypg
docker pause mypg
docker unpause mypg
docker rm mypg
docker rm -f mypg                             # force remove a running container

# Inspect
docker inspect mypg
docker port mypg                              # published port mappings
docker stats                                  # live CPU/mem/network usage
docker top mypg                               # processes running inside
```

### Common `docker run` flags

| Flag | Purpose |
|---|---|
| `-d` | Detached (background) |
| `-it` | Interactive TTY (shells, REPLs) |
| `--rm` | Auto-remove container on exit |
| `-p host:container` | Publish a port |
| `-v host:container` | Bind-mount a host path |
| `-e KEY=value` | Set an environment variable |
| `--env-file .env` | Load env vars from a file |
| `--name` | Give the container a fixed name |
| `--network` | Attach to a specific network |

---

## Logs & Exec

```bash
# Follow logs
docker logs -f mypg
docker logs --tail 100 mypg
docker logs --since 10m mypg

# Run a command inside a running container
docker exec -it mypg bash
docker exec -it mypg psql -U postgres

# Copy files in/out
docker cp mypg:/var/lib/postgresql/data ./backup
docker cp ./init.sql mypg:/init.sql
```

---

## Volumes

Named volumes persist data beyond a container's lifecycle — use these for databases instead of relying on the container filesystem.

```bash
docker volume create pgdata
docker volume ls
docker volume inspect pgdata
docker volume rm pgdata
docker volume prune                           # remove all unused volumes

# Use a named volume
docker run -d -v pgdata:/var/lib/postgresql/data postgres:17
```

---

## Networks

```bash
docker network ls
docker network create mynet
docker network inspect mynet
docker network rm mynet

# Attach a running container to a network
docker network connect mynet mypg
```

Containers on the same user-defined network resolve each other by container name — no manual IP wiring needed.

---

## Docker Compose

Compose defines multi-container setups declaratively in `compose.yaml` (formerly `docker-compose.yml`). `docker compose` (space, no hyphen) is the built-in v2 CLI shipped with Docker Desktop.

### Example `compose.yaml`

```yaml
services:
  db:
    image: postgres:17
    environment:
      POSTGRES_PASSWORD: secret
    ports:
      - "5432:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

  app:
    build: .
    depends_on:
      - db
      - redis
    ports:
      - "3000:3000"
    env_file:
      - .env

volumes:
  pgdata:
```

### Daily commands

```bash
docker compose up                             # foreground, all services
docker compose up -d                          # detached
docker compose up -d --build                  # rebuild images first
docker compose ps
docker compose logs -f
docker compose logs -f app                    # single service

docker compose stop
docker compose down                           # stop + remove containers/networks
docker compose down -v                        # also remove named volumes (destructive)

docker compose exec app bash
docker compose restart app
docker compose build --no-cache app
```

**Tip:** `docker compose up -d && docker compose logs -f` is the fastest way to start a stack and immediately watch it boot.

---

## Dockerfile Basics

```dockerfile
FROM node:22-slim

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci --omit=dev

COPY . .

EXPOSE 3000
CMD ["node", "server.js"]
```

### Layer caching order

Put things that change least often first (base image, dependency manifests) and things that change most often last (source code). This lets Docker reuse cached layers on rebuilds instead of reinstalling dependencies every time.

### Multi-stage builds (smaller final images)

```dockerfile
FROM node:22 AS build
WORKDIR /app
COPY . .
RUN npm ci && npm run build

FROM node:22-slim
WORKDIR /app
COPY --from=build /app/dist ./dist
COPY package.json package-lock.json ./
RUN npm ci --omit=dev
CMD ["node", "dist/server.js"]
```

### `.dockerignore`

```
node_modules
.git
.env
*.log
dist
```

Keeps build context small and avoids leaking secrets or bloating layers.

---

## Cleaning Up Disk Space

Docker Desktop's VM disk grows over time with unused images, stopped containers, and dangling layers.

```bash
# See what's using space
docker system df

# Remove stopped containers, dangling images, unused networks
docker system prune

# Also remove unused (not just dangling) images
docker system prune -a

# Also remove unused volumes (destructive — check first with `docker volume ls`)
docker system prune -a --volumes
```

**Note:** `--volumes` deletes any named volume not referenced by a running container. Back up data you care about before running it.

For a hard reset via the GUI: Docker Desktop → Settings → Troubleshoot → "Clean / Purge data" or "Reset to factory defaults."

---

## Common Pitfalls

### `docker` command hangs or "Cannot connect to the Docker daemon"

Docker Desktop isn't running. Launch it (`open -a Docker`) and wait for the whale icon in the menu bar to stop animating.

### Docker Desktop window looks fine, but CLI still can't connect to the socket

```
Cannot connect to the Docker daemon at unix:///Users/<you>/.docker/run/docker.sock. Is the docker daemon running?
```

The Electron app/tray can stay open and still show your last-known container list even after the actual engine (the process that serves the socket) has died or failed to start — the Containers tab is rendering cached state, not a live query. Confirm this is what's happening:

```bash
docker desktop status
# "Could not retrieve status. Is Docker Desktop running?" confirms the engine is down
```

Fix it straight from the CLI — no need to click the tray icon. Docker Desktop ships a `docker desktop` CLI plugin:

```bash
docker desktop restart      # stop + start the engine, waits until it's ready
docker desktop status       # re-check once it returns
docker ps                   # should work again
```

If `restart` doesn't help, escalate:

```bash
docker desktop stop
docker desktop start
```

As a last resort (or if the `docker desktop` plugin itself is unresponsive), quit and relaunch the whole app:

```bash
killall Docker
open -a Docker
```

`docker context ls`, the `docker` binary symlink (`/usr/local/bin/docker` or `/opt/homebrew/bin/docker`), and the socket path are almost never the actual problem here — check `docker desktop status` first before chasing context/symlink config.

### Port already in use

```bash
# Find what's bound to the port
lsof -i :5432

# Or just pick a different host port
docker run -p 5433:5432 postgres:17
```

### Postgres/Redis conflicts with Homebrew-installed services

This setup intentionally omits `postgresql`/`redis` formulae from the `Brewfile` in favor of running them in Docker — see [`README.md` — Design Decisions](../README.md#design-decisions-short-version). If you also brew-installed a local Postgres/Redis at some point, stop it before starting the containerized version to avoid a port clash:

```bash
brew services stop postgresql@17
brew services stop redis
```

### Changes to a bind-mounted file aren't reflected

Confirm the mount is actually a bind mount (`-v $(pwd):/app`), not a named volume, and that the path on the host side is correct. `docker inspect <container> --format '{{json .Mounts}}'` shows the resolved mapping.

### Build is slow / not using cache

Reorder the Dockerfile so rarely-changing steps (base image, dependency install) come before frequently-changing steps (source copy). See [Layer caching order](#layer-caching-order).

### Apple Silicon / architecture mismatches

Images built on or pulled for `linux/amd64` may run under emulation (slow, or fail outright) on Apple Silicon. Check and target the right platform explicitly:

```bash
docker inspect --format '{{.Os}}/{{.Architecture}}' postgres:17
docker build --platform linux/arm64 -t myapp:latest .
docker buildx build --platform linux/amd64,linux/arm64 -t myapp:latest --push .
```

### Disk filling up

Run `docker system df` periodically and `docker system prune` when the VM disk grows unexpectedly. Docker Desktop's virtual disk doesn't shrink automatically even after files are deleted inside it — Settings → Resources → Advanced lets you cap or reclaim the disk image size.

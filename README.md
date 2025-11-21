# stardew-multiplayer (containerized)

A small container image and compose setup to run a Stardew Valley instance with a headless X session exposed via noVNC and a `filebrowser` UI for managing mods.

## Quick start

1. Place your Stardew game files into the `install_directory/` folder on the host. The container expects the game binary under `/home/app/games/game/`.
2. Add any mods to the `mods/` folder on the host — they will be mounted to `/home/app/games/game/Mods` inside the container.
3. Place your save files into the `saves/` folder on the host — they will be mounted to `/home/app/.config/StardewValley/Saves` inside the container.
3. Build and run with Docker Compose:

```bash
docker compose build
docker compose up
# use `-d` to run in the background: docker compose up -d
```

### Alternative: build and run with `docker` directly

```bash
docker build -t stardew-multiplayer .
docker run --rm -it \
  -p 8080:8080 \
  -p 8081:8081 \
  -p 24642:24642/udp \
  -v $(pwd)/install_directory:/home/app/games \
  -v $(pwd)/mods:/home/app/games/game/Mods \
  -v $(pwd)/saves:/home/app/.config/StardewValley/Saves \
  stardew-multiplayer
```

## Deployment (docker-compose)

Save the snippet below as `docker-compose.yml` next to `install_directory` and `mods`, then run:

```bash
docker compose -f docker-compose.yml up -d
```

```yaml
services:
  stardew:
    image: icyavocado/stardew-multiplayer:latest # replace with your image or use `build: .`
    container_name: stardew_multiplayer
    restart: unless-stopped
    ports:
      - '8080:8080'    # noVNC
      - '8081:8081'    # filebrowser
      - '24642:24642/udp' # Stardew UDP
    volumes:
      - ./install_directory:/home/app/games:ro
      - ./mods:/home/app/games/game/Mods:rw
      - ./saves:/home/app/.config/StardewValley/Saves:rw
```

Notes:
- Use `build: .` if you want to build the image on the host instead of pulling from a registry.
- Ensure `install_directory` contains the game files before starting the container.

## Key concepts
- The container is driven by `supervisord` (`supervisord.conf`) which starts `Xvfb`, `x11vnc`, `openbox`, `novnc`, `filebrowser`, and the `stardewvalley` binary.
- `startup.sh` is the entrypoint: it optionally patches screen resolution, starts `supervisord`, renames the game binary (if present), and tails logs in `/home/app/logs`.
- Game files are mounted from the host `install_directory/` into the container at `/home/app/games`. Mods are mounted from `mods/` into `/home/app/games/game/Mods`.

## Important files
- `Dockerfile` — base image and installed packages (supervisor, novnc, x11vnc, Xvfb, filebrowser installer).
- `docker-compose.yml` — mounts, ports, and entrypoint mapping to `startup.sh`.
- `startup.sh` — edits resolution (via `RESOLUTION` env var), starts `supervisord`, renames the binary `StardewValley` → `Stardew Valley` if present, and tails logs.
- `supervisord.conf` — program definitions and startup order. Notice `check_and_run` is used to wait for dependencies.
- `check_and_run` — helper script used by `supervisord` commands to poll `supervisorctl status` for ready signals.

## Logs and debugging
- Supervisor-managed processes write logs to `/home/app/logs` inside the container. To inspect logs from the host:

```bash
docker compose logs -f stardev_valley
# or
docker logs -f stardev_valley
```

- To get an interactive shell inside the running container:

```bash
docker exec -it stardev_valley /bin/bash
# then run: supervisorctl status
# and: ls -la /home/app/logs
```

## Notes and gotchas
- Binary rename: `startup.sh` renames `/home/app/games/game/StardewValley` to `/home/app/games/game/Stardew Valley` if a file with the former name exists. Avoid conflicting file operations unless you expect this behavior.
- Readiness ordering: many `supervisord` commands use the `check_and_run` script to wait for another program to be `RUNNING` before continuing (e.g., `x11vnc` waits for `xvfb`). Preserve these guards if you modify `supervisord.conf` to prevent races.
- `filebrowser` is configured at container start to init config and add a `stardewvalley` user (see `supervisord.conf` for the exact command sequence).

## Road Map

1. Create configurable variables for `filebrowser`, and game resolution

## Contributing
- Keep image changes minimal and layered sensibly. If adding packages in `Dockerfile`, maintain the `USER app` and `WORKDIR /home/app` semantics.
- If you change compose mounts or ports, please update this `README.md` to keep local developer instructions accurate.

## Where to look next
- `startup.sh`, `supervisord.conf`, `Dockerfile`, `docker-compose.yml`, and `check_and_run`.

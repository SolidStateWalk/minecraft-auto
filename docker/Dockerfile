FROM itzg/minecraft-server:latest

LABEL maintainer="Acme Corp SysAdmin"
LABEL description="Vanilla Minecraft Java Edition server — Acme Corp build"

VOLUME ["/data"]
EXPOSE 25565/tcp

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD mc-health || nc -z localhost 25565 || exit 1

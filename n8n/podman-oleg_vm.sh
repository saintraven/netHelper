#!/usr/bin/env bash
# Запуск на oleg_vm (user artem), из каталога с заполненным .env
set -euo pipefail
IMAGE="${N8N_IMAGE:-docker.io/n8nio/n8n:1.70.1}"
NAME="${N8N_CONTAINER_NAME:-hackathon-n8n}"
VOLUME="${N8N_VOLUME:-hackathon-n8n-data}"
ENV_FILE="${ENV_FILE:-.env}"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Missing $ENV_FILE — copy from .env.example" >&2
  exit 1
fi

podman run -d --name "$NAME" --replace \
  -p 5678:5678 \
  -v "${VOLUME}:/home/node/.n8n" \
  --env-file "$ENV_FILE" \
  "$IMAGE"

echo "n8n: http://127.0.0.1:5678 (ssh -L 5678:127.0.0.1:5678 oleg_vm)"
# n8n (Артём · AI workflow)

Базовый шаблон под хакатон: **Prometheus → нормализация JSON v1.0 → DeepSeek (`deepseek-flash`) → текст алерта** (почту подключить нодой Send Email).

## Файлы

| Файл | Назначение |
|------|------------|
| `workflows/network-monitoring.json` | Импорт в n8n (Settings → Import) |
| `scripts/normalize-prometheus.js` | Копия кода из Code-ноды |
| `prompts/analysis-system.txt` | Расширенный system prompt |
| `compose.yml` | Вставка для `infra/docker-compose` (Илья) |
| `.env.example` | Переменные |

## DeepSeek Flash

OpenAI-совместимый API: `POST https://api.deepseek.com/chat/completions`, модель **`deepseek-flash`** ([документация](https://api-docs.deepseek.com/)).

В workflow ключ передаётся через `DEEPSEEK_API_KEY` в окружении контейнера (не коммитить).

## `oleg_vm` — насколько реально поднять n8n

Проверено на хосте **`pub`** (SSH: `oleg_vm` → user **artem**, `oleg_vm_work` → **work**; алиас `work_oleg_vm` в `~/.ssh/config` нет).

| Фактор | Состояние |
|--------|-----------|
| Контейнеры | На хосте **podman 4.9.3** (docker CLI нет). **artem**: rootless podman, образ `n8nio/n8n:1.70.1` уже тянется. **work**: заняты `apivm`, `smoke_api`, `webtest` — n8n лучше не класть туда. |
| RAM | ~23 GiB, ~20 GiB available — для n8n более чем достаточно. |
| Диск | **/dev/sda1 ~98% занят (≈2.6 GiB свободно)** — главный риск. Перед продолжением: `podman system prune`, чистка старых образов у work/artem, согласовать с Ильёй. |
| Сеть | Tailscale на `100.79.14.102`; порт **5678** сейчас свободен. UI: `http://<tailscale-ip>:5678` или SSH-туннель. |
| Prometheus | Пока не поднят на VM — в `.env` временно `PROMETHEUS_URL=http://localhost:9090` или IP compose-стека Ильи. Из podman-сети команды обычно `http://prometheus:9090`. |
| DeepSeek | Локальная модель не нужна — только исходящий HTTPS в `api.deepseek.com`. |

**Вывод:** поднять n8n на **`oleg_vm` под пользователем artem** — **реально и уже проверено pull'ом образа**. Для хакатона логичнее так, чем лезть в podman **work** с `apivm`. Но **освободи диск** и зафиксируй с Ильёй URL Prometheus.

### Быстрый запуск (artem @ oleg_vm)

```bash
mkdir -p ~/hackathon-n8n-data
cd ~
cp /path/to/.env.example .env   # заполнить DEEPSEEK_API_KEY, TARGET_ID, PROMETHEUS_URL

podman run -d --name hackathon-n8n \
  --replace \
  -p 5678:5678 \
  -v hackathon-n8n-data:/home/node/.n8n \
  --env-file .env \
  docker.io/n8nio/n8n:1.70.1
```

С Windows (туннель к UI):

```powershell
ssh -L 5678:127.0.0.1:5678 oleg_vm
```

Дальше: http://localhost:5678 → import `workflows/network-monitoring.json`.

### Интеграция с общим compose

Илья подключает сервис из `compose.yml` в `infra/`, чтобы n8n и Prometheus были в одной сети `monitoring`. Ты только задаёшь env и экспортируешь workflow в репозиторий.

## Следующие шаги (backlog)

1. Добавить HTTP-запросы для `probe_duration_seconds` / `probe_http_status_code` или один PromQL batch.
2. Нода **Send Email** после `Format alert` (SMTP из `.env`).
3. **Schedule Trigger** вместо Manual (интервал 1–5 мин).
4. Обработка ветки `unknown` при partial/unavailable `data_quality`.
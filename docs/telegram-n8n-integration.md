# Telegram ↔ n8n (без публичного порта 443)

## Решение

| Параметр | Значение |
|----------|----------|
| Режим | **Long polling** (`getUpdates`), не webhook |
| Причина | Bot API принимает webhook только на **443 / 80 / 88 / 8443**; публичный **443 недоступен** |
| UI n8n | `http://127.0.0.1:49980` (SSH `-L`, пользователь **work**) |
| Исходящий трафик | VPN HTTPS-прокси (`/home/artem/vpn-proxy.conf` → env в контейнере n8n) |
| Входящие порты для Telegram | **Не требуются** |

Штатный **Telegram Trigger (webhook)** в этом окружении **не используется**.

## Ограничения (зафиксировать в README / демо)

- Один бот — **один** активный polling (один опубликованный workflow с polling-триггером).
- Перед включением polling — **`deleteWebhook`** (иначе `getUpdates` пустой).
- Только **исходящие** HTTPS-запросы к `api.telegram.org` (совместимо с корпоративным прокси).

## Шаги на n8n (work @ oleg_vm)

### 1. Убрать webhook у бота (один раз)

В n8n: **HTTP Request** (или разовый curl с ВМ через прокси):

- `GET https://api.telegram.org/bot<TOKEN>/deleteWebhook`
- Проверка: `GET .../getWebhookInfo` → `url` пустой.

### 2. Community-нода polling

**Settings → Community nodes → Install:**

`@mentoster/n8n-nodes-telegram-polling`

(альтернатива: `n8n-nodes-telegram-polling` / fork bergi9 — тот же принцип.)

Перезапуск/обновление страницы UI при необходимости.

### 3. Workflow

1. **Telegram Trigger (long polling)** — типы updates: `message` (и при необходимости `callback_query`).
2. Дальше: существующая цепочка (Prometheus, LLM, ответ в TG через **Telegram** node).
3. **Publish** workflow (polling работает в активном workflow).

### 4. Credentials

- Telegram API credential с **bot token** (от @BotFather).
- Токен не коммитить.

### 5. Env контейнера (уже есть)

`HTTP_PROXY`, `HTTPS_PROXY`, `NO_PROXY` — без публичного `WEBHOOK_URL` на https.

## Тест

1. Написать боту в личку (или добавить в группу с privacy off, если нужны группы).
2. Сообщение должно запустить workflow (смотреть **Executions**).
3. Алерты «снизу вверх» — отдельный workflow: **Schedule** → метрики → **Telegram Send Message** (тоже без webhook).

## Для демо / сдачи (один абзац)

«Интеграция с Telegram реализована через **long polling** Bot API: экземпляр n8n не публикует webhook и не требует входящего HTTPS на 443; взаимодействие с Telegram — исходящие запросы через согласованный HTTPS-прокси. Уведомления оператору — ноды **Telegram** (sendMessage).»

## Не делать

- **Telegram Trigger (webhook)** при `WEBHOOK_URL=http://127.0.0.1:49980/` — всегда ошибка `HTTPS URL must be provided`.
- HTTPS на **49980** для webhook — порт не входит в список Telegram.
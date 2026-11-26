# Credential «Telegram» в n8n

**«Telegram Bot netHelper» в списке не появится сам** — это имя, которое ты задаёшь при создании. В каталоге n8n есть только тип **Telegram API**.

## Создать (один раз)

1. В n8n: левое меню **Credentials** (значок ключа), не список внутри ноды.
2. **Add credential** (или **Create credential**).
3. В поиске: `Telegram` → выбрать **Telegram API** (иконка Telegram, не HTTP Request).
4. **Access Token** — токен от @BotFather.
5. **Save as** / имя credential: **`Telegram Bot netHelper`** (любое имя, но одно на весь проект).
6. **Save**.

## Привязать к workflow

1. Открой workflow **netHelper · Telegram long polling**.
2. Кликни ноду **Telegram long polling** (или **Reply check**).
3. Поле **Credential for Telegram API** → выпадающий список → выбери созданный **`Telegram Bot netHelper`**.
   - Если пусто: **Create new credential** → снова **Telegram API** → токен → Save.
4. Повтори для **Reply start**, **Reply check**, **Reply other** (тот же credential).

## Если в Add credential нет «Telegram API»

- Обнови страницу n8n после рестарта контейнера.
- Проверь, что импортирован workflow с нодой **`Telegram long polling`** (community), а не старый **Telegram Trigger** (webhook) — на webhook при ненастроенном URL будет та же ошибка HTTPS.
- На VM должно быть: `N8N_CUSTOM_EXTENSIONS=/home/node/.n8n/custom` и установлен пакет polling (см. `n8n/git/README.md`).

## Не путать

| В UI | Это |
|------|-----|
| **Telegram API** | Тип credential (выбираешь в каталоге) |
| **Telegram Bot netHelper** | Твоё имя сохранённого credential |
| **Telegram Trigger** (без «long polling») | Webhook — **не использовать** без 443 |
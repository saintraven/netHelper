# Git: netHelper / n8n_agent

| | |
|--|--|
| Remote | `git@github.com:saintraven/netHelper.git` |
| Branch | `n8n_agent` |
| SSH identity | user **node** in container **n8n** (work @ oleg_vm) |

## Deploy key (GitHub)

1. Repo → **Settings → Deploy keys → Add deploy key**
2. Title: `n8n@oleg_vm`
3. Key: contents of `/home/node/.ssh/id_ed25519_nethelper.pub` on the container (read-only is enough for pull; enable write if n8n should push).

```bash
ssh oleg_vm_work "podman exec -u node n8n cat /home/node/.ssh/id_ed25519_nethelper.pub"
```

4. After save, test:

```bash
ssh oleg_vm_work "podman exec -u node n8n ssh -T git@github.com"
```

Expected: `Hi saintraven/netHelper! You've successfully authenticated...`

## Layout in repo

```
n8n/workflows/*.json
n8n/prompts/
n8n/scripts/
docs/telegram-n8n-integration.md
```

Secrets (`DEEPSEEK_API_KEY`, bot tokens) — only in `n8n.env` on the VM, not in git.
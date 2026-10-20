---
last_verified: 2026-10-20
tool_version: n/a
---

# app_role

Reusable role scaffold tested with Molecule and gated by CI.

## Role variables

| Variable | Description | Default |
|---|---|---|
| `app_user` | System user that owns the application files | `app_user` |
| `app_dir` | Application install directory | `/opt/app_role` |
| `app_config_path` | Path to the rendered configuration file | `/etc/app_role/app.conf` |
| `app_service` | Service name to restart on change | `app_role` |

## Example playbook

```yaml
- hosts: all
  roles:
    - role: app_role
```

## License

MIT

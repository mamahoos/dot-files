# dot-files

Minimal, versioned dotfiles for a Linux development setup. Layout mirrors the filesystem: `home/` → `$HOME`, `config/` → `$XDG_CONFIG_HOME`.

## What Gets Installed

These paths are copied or symlinked into your system — they are **your dotfiles**:

- Shell and git config under `home/`
- XDG tool configs under `config/` (btop, htop, tmux)
- Cursor rules, skills, and agents under `home/.cursor/`

## Repository Structure

```text
.
├── home/                          # dotfiles → ~
├── config/                        # dotfiles → ~/.config
├── install.sh                     # symlink dotfiles into place
├── .github/
│   ├── workflows/                 # CI
│   └── scripts/
│       └── sync-agent-skills.sh   # repo maintenance (not installed)
└── README.md
```

## Setup

> **Note:** This repo is mainly a reference. Prefer copying the configs you want into your own paths and adapting them. `install.sh` is provided for convenience only — symlinks can interact badly with tools that rewrite config files, and a bad link pass can leave your live setup in a messy state.

```bash
./install.sh   # optional; use at your own risk
```

`home/*` links to `$HOME`, `config/*` links to `$XDG_CONFIG_HOME` (default `~/.config`). Existing targets are backed up under `~/.dotfiles-backup/`.

`.cursor` children (`agents`, `rules`, `skills`) link individually into `~/.cursor/` so Cursor-managed paths are not replaced.

## Cursor Skills

Skills live in `home/.cursor/skills/` and cover planning, testing, review, debugging, and delivery workflows.

### Attribution

Core skill content is sourced from [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills.git), then adapted locally.

Rules in `home/.cursor/rules/` are project-specific and not part of upstream.

### Sync upstream skills (maintainers)

For contributors updating skills from upstream:

```bash
./.github/scripts/sync-agent-skills.sh --pull
git diff home/.cursor/skills
```

First run creates `.cache/agent-skills` (gitignored). `--pull` updates it before syncing.

> **Optional:** Already have a clone? `AGENT_SKILLS_DIR=/path/to/agent-skills ./.github/scripts/sync-agent-skills.sh --pull`  
> **Read-only?** Skip sync — copy from `home/.cursor/skills/` directly.

CI runs the same check via the `agent-skills` workflow; drift on `main` opens a sync PR automatically.

## TODO

- [ ] Add tmux configuration (`config/tmux/tmux.conf`)
- [ ] Add Poetry global configuration (`config/poetry/config.toml`)
- [ ] Add VS Code user settings (`config/vscode/settings.json`)

## License

Personal dotfiles and workflow assets. You can reference and adapt them for your own setup.

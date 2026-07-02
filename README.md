# dot-files

Minimal, versioned dotfiles for a Linux development setup. Layout mirrors the filesystem: `home/` → `$HOME`, `config/` → `$XDG_CONFIG_HOME`.

## What This Repo Contains

- Shell and git config under `home/`
- XDG tool configs under `config/` (btop, htop, tmux)
- Cursor rules, skills, and agents under `home/.cursor/`

## Repository Structure

```text
.
├── home/                          # mirrors $HOME
│   ├── .bashrc
│   ├── .bash_aliases
│   ├── .bash_functions
│   ├── .bashrc.local.example
│   ├── .profile
│   ├── .gitconfig
│   └── .cursor/
│       ├── agents/
│       ├── rules/                 # Cursor rules (.mdc)
│       └── skills/                # synced from addyosmani/agent-skills
├── config/                        # mirrors ~/.config
│   ├── btop/
│   ├── htop/
│   └── tmux/
├── scripts/
│   ├── link-dotfiles.sh           # symlink home/ and config/ into place
│   └── sync-agent-skills.sh       # pull upstream skills
├── .github/workflows/
│   ├── lint.yml
│   └── skills-drift.yml
└── README.md
```

## Setup

> **Note:** This repo is mainly a reference. Prefer copying the configs you want into your own paths and adapting them. `link-dotfiles.sh` is provided for convenience only — symlinks can interact badly with tools that rewrite config files, and a bad link pass can leave your live setup in a messy state.

```bash
./scripts/link-dotfiles.sh   # optional; use at your own risk
```

`home/*` links to `$HOME`, `config/*` links to `$XDG_CONFIG_HOME` (default `~/.config`). Existing targets are backed up under `~/.dotfiles-backup/`.

`.cursor` children (`agents`, `rules`, `skills`) link individually into `~/.cursor/` so Cursor-managed paths are not replaced.

## Cursor Skills

Skills live in `home/.cursor/skills/` and cover planning, testing, review, debugging, and delivery workflows.

### Attribution

Core skill content is sourced from [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills.git), then adapted locally.

Rules in `home/.cursor/rules/` are project-specific and not part of upstream.

### Sync upstream skills

```bash
./scripts/sync-agent-skills.sh --pull   # clones upstream on first run
git diff home/.cursor/skills
```

First run creates `.cache/agent-skills` (gitignored). `--pull` updates it before syncing.

> **Optional:** Already have a clone? `AGENT_SKILLS_DIR=/path/to/agent-skills ./scripts/sync-agent-skills.sh --pull`  
> **Read-only?** Skip sync — copy from `home/.cursor/skills/` directly.

CI clones upstream on each run; locally the script handles clone/pull for you.

## TODO

- [ ] Add tmux configuration (`config/tmux/tmux.conf`)
- [ ] Add Poetry global configuration (`config/poetry/config.toml`)
- [ ] Add VS Code user settings (`config/vscode/settings.json`)

## License

Personal dotfiles and workflow assets. You can reference and adapt them for your own setup.

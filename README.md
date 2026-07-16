# dot-files

**My dotfiles & environment setup**

Versioned Linux configs I use day to day. The repo mirrors the filesystem: `home/` → `$HOME`, `config/` → `~/.config`.

## What's in here

| Path | Contents |
| --- | --- |
| `home/` | Bash, git, Cursor (rules, agents, skills) |
| `config/` | btop, htop, tmux |
| `install.sh` | Symlink `home/` and `config/` into place |

## Structure

```text
.
├── home/
│   ├── .bashrc, .bash_aliases, .bash_functions
│   ├── .gitconfig
│   └── .cursor/
│       ├── agents/
│       ├── rules/
│       └── skills/
├── config/
│   ├── btop/
│   ├── htop/
│   └── tmux/
├── install.sh
└── .github/          # CI & repo scripts (not installed)
```

## Setup

> [!WARNING]
> This symlinks configs into your home directory. Anything replaced is moved to `~/.dotfiles-backup/`. Use at your own risk.

```bash
./install.sh
```

`.cursor` children link individually into `~/.cursor/` so Cursor-managed paths are not replaced wholesale.

## Cursor skills

Skills under `home/.cursor/skills/` come from versioned upstreams (see `.github/upstreams/`) plus any local-only dirs you add by hand. Sync with `./.github/scripts/sync-upstreams.sh --pull`.

| Skill dirs | Upstream | Path in upstream | Local overlay |
| --- | --- | --- | --- |
| `home/.cursor/skills/*` (default set) | [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) ([MIT](https://github.com/addyosmani/agent-skills/blob/main/LICENSE)) | `skills/` | `disable-model-invocation: true`, idea-refine path fix |
| `home/.cursor/skills/ui-ux-pro-max/` | [nextlevelbuilder/ui-ux-pro-max-skill](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill) ([MIT](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill/blob/main/LICENSE)) | `.claude/skills/ui-ux-pro-max/` | `*.py` / tests excluded from the repo |

Rules and any skill dirs not listed above are mine (unmanaged by sync).

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

Some skills under `home/.cursor/skills/` are adapted from [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) ([MIT](https://github.com/addyosmani/agent-skills/blob/main/LICENSE)). Rules and the rest are mine.

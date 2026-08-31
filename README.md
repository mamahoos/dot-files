# dot-files

**My dotfiles & environment setup**

Versioned Linux configs I use day to day.

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
│   ├── .bashrc, .bash_aliases, .bash_functions, .inputrc
│   ├── .gitconfig, .gitmessage
│   └── .cursor/
│       ├── agents/
│       ├── rules/
│       └── skills/
├── config/
│   ├── btop/
│   ├── htop/
│   └── tmux/
├── install.sh
├── Makefile          # local stand-ins for CI (`make help`)
└── .github/          # CI & repo scripts (not installed)
```

## Setup

> [!WARNING]
> This symlinks configs into your home directory. Anything replaced is moved to `~/.dotfiles-backup/`. Use at your own risk.

```bash
./install.sh
```

`.cursor` children link individually into `~/.cursor/` so Cursor-managed paths are not replaced wholesale.

## Local checks

Same commands CI runs locally. `make` prints targets; `make check` runs the full set (ShellCheck, shfmt, install smoke/idempotent, skills drift).

```bash
make check
```

## Cursor skills

Skills under `home/.cursor/skills/` come from versioned upstreams (see `.github/upstreams/`) plus any local-only dirs you add by hand. Sync with `./.github/scripts/sync-upstreams.sh --pull`.

| Skill dirs | Upstream | Path in upstream | Local overlay |
| --- | --- | --- | --- |
| `home/.cursor/skills/*` (default set) | [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) ([MIT](https://github.com/addyosmani/agent-skills/blob/main/LICENSE)) | `skills/` | `disable-model-invocation: true`, idea-refine path fix |
| `home/.cursor/skills/ui-ux-pro-max/` | [nextlevelbuilder/ui-ux-pro-max-skill](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill) ([MIT](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill/blob/main/LICENSE)) | `.claude/skills/ui-ux-pro-max/` | search.py path rewritten to `$HOME/.cursor/skills/...` (`scripts/` vendored for linguist) |
| `home/.cursor/skills/i-have-adhd/` | [ayghri/i-have-adhd](https://github.com/ayghri/i-have-adhd) ([MIT](https://github.com/ayghri/i-have-adhd/blob/main/LICENSE)) | `.cursor/skills/i-have-adhd/` | none (`disable-model-invocation` already in upstream) |
| `home/.cursor/skills/resume-builder/` | [dabydat/resume-builder-skill](https://github.com/dabydat/resume-builder-skill) ([MIT](https://github.com/dabydat/resume-builder-skill/blob/master/LICENSE)) | `skill/` | `disable-model-invocation: true` |
| `home/.cursor/skills/find-skills/` | [vercel-labs/skills](https://github.com/vercel-labs/skills) ([MIT](https://github.com/vercel-labs/skills/blob/main/LICENSE)) | `skills/find-skills/` | `disable-model-invocation: true` |

Rules and any skill dirs not listed above are mine (unmanaged by sync).

## License

This repository is [MIT licensed](LICENSE). Synced Cursor skills remain under their upstream licenses (see table above).

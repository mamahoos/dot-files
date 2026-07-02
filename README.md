# dot-files

Minimal, versioned dotfiles for a Linux development setup, including shell and tool configuration, SSH templates, and Cursor skills.

## What This Repo Contains

- Bash configuration files (`.bashrc`, aliases, profile, local override template)
- Git and CLI tool configs (`.gitconfig`, `htop`, `btop`, `tmux`, `vscode`)
- Cursor skills and agent guidance under `.cursor/`

## Repository Structure

```text
.
├── bash/                          # Bash shell configuration
│   ├── .bash_aliases
│   ├── .bashrc
│   ├── .bashrc.local.example
│   └── .profile
├── config/                        # System tool configurations
│   ├── btop/
│   │   └── btop.conf
│   ├── htop/
│   │   └── htoprc
│   └── tmux/
│       └── .gitkeep
├── git/                           # Git configuration
│   └── .gitconfig
├── .cursor/                       # Cursor skills, rules, and agents
│   ├── rules/                     # Always-on / conditional Cursor rules (.mdc)
│   ├── skills/                    # Synced from addyosmani/agent-skills
│   └── agents/
├── scripts/
│   └── sync-agent-skills.sh       # Pull upstream skills into .cursor/skills
└── link-dotfiles.sh               # Symlink setup script
```

## Cursor Skills

The `.cursor/skills/` directory contains reusable guidance and workflows for development tasks such as:

- Planning and implementation
- Testing and quality checks
- Code review and debugging
- Automation and delivery practices

## Skills Attribution

Core skill content in `.cursor/skills/` is sourced from [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills.git), then adapted for personal workflow and local usage.

Project-specific Cursor rules live in `.cursor/rules/` (`.mdc` files). These are **not** part of upstream agent-skills; they point agents at the synced skills.

### Sync upstream skills

Vendor checkout (default): `~/dev/vendor/agent-skills`

```bash
./scripts/sync-agent-skills.sh --pull   # pull upstream, sync, apply local overlay
git diff .cursor/skills                 # review before commit
```

The sync script copies upstream `skills/`, then applies local overlay:
- `disable-model-invocation: true` on each skill
- fix `idea-refine` script path for this repo layout

CI runs `skills-drift` on changes under `.cursor/skills/**` (plus a weekly schedule) and fails when local skills drift from upstream. Fix with `./scripts/sync-agent-skills.sh --pull`, review, commit.

## TODO

- [ ] Add tmux configuration (`config/tmux/tmux.conf`)
- [ ] Add Poetry global configuration (`config/poetry/config.toml`)
- [ ] Add VS Code user settings (`config/vscode/settings.json`)

## License

Personal dotfiles and workflow assets. You can reference and adapt them for your own setup.

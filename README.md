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
├── .cursor/                       # Cursor skills and agents
│   ├── skills/
│   └── agents/
└── link-dotfiles.sh               # Symlink setup script
```

## Cursor Skills

The `.cursor/skills/` directory contains reusable guidance and workflows for development tasks such as:

- Planning and implementation
- Testing and quality checks
- Code review and debugging
- Automation and delivery practices

## Skills Attribution

Core skill content in this repository is sourced from [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills.git), then adapted for personal workflow and local usage.

## TODO

- [ ] Add tmux configuration (`config/tmux/tmux.conf`)
- [ ] Add Poetry global configuration (`config/poetry/config.toml`)
- [ ] Add VS Code user settings (`config/vscode/settings.json`)

## License

Personal dotfiles and workflow assets. You can reference and adapt them for your own setup.

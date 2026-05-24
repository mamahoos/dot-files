# dot-files

Minimal, versioned dotfiles for a Linux development setup, including shell and tool configuration, SSH templates, and Cursor skills.

## What This Repo Contains

- Bash configuration files (`.bashrc`, aliases, profile, local override template)
- Git and CLI tool configs (`.gitconfig`, `htop`, `btop`)
- SSH configuration templates with an organized `config.d/` layout
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
├── ssh/                           # SSH configuration templates
│   ├── .gitignore
│   ├── config.example
│   └── config.d/
│       └── organization.example
├── .cursor/                       # Cursor skills and agents
│   ├── skills/
│   └── agents/
└── link-dotfiles.sh               # Symlink setup script
```

## Quick Start

1. Clone the repository:

   ```bash
   git clone https://github.com/mamahoos/dot-files.git ~/dot-files
   cd ~/dot-files
   ```

2. Link dotfiles into your home directory:

   ```bash
   ./link-dotfiles.sh
   ```

3. Apply local customizations:

   - Copy `bash/.bashrc.local.example` to `bash/.bashrc.local`
   - Add machine-specific settings in `bash/.bashrc.local`
   - Customize SSH hosts under `ssh/config.d/`

## SSH Notes

Files in `ssh/` are templates and examples only:

- No private keys are included
- No real hostnames or infrastructure secrets are included
- Use `config.d/` to split host definitions by team, environment, or purpose

## Cursor Skills

The `.cursor/skills/` directory contains reusable guidance and workflows for development tasks such as:

- Planning and implementation
- Testing and quality checks
- Code review and debugging
- Automation and delivery practices

## Skills Attribution

Core skill content in this repository is sourced from [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills.git), then adapted for personal workflow and local usage.

## License

Personal dotfiles and workflow assets. You can reference and adapt them for your own setup.

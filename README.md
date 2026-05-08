# dot-files

Minimal, versioned dotfiles for my Linux setup with organized configurations and development skills.

## Overview

This repository contains:
- **Configuration files** for bash, git, and system tools (htop, btop)
- **SSH templates** for structured host configuration
- **Development skills** - a curated collection of best practices and techniques

## Structure

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
│   └── htop/
│       └── htoprc
├── git/                           # Git configuration
│   └── .gitconfig
├── ssh/                           # SSH configuration templates
│   ├── .gitignore
│   ├── config.example
│   └── config.d/
│       └── organization.example
├── .cursor/                       # Development skills and agents
│   ├── skills/                    # Curated skills and frameworks
│   └── agents/
└── link-dotfiles.sh               # Setup script
```

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/mamahoos/dot-files.git ~/dot-files
   cd ~/dot-files
   ```

2. Run the symlink script:
   ```bash
   ./link-dotfiles.sh
   ```

   This script creates symlinks from configuration files to their expected locations in `$HOME`.

3. Customize as needed:
   - Copy `.bashrc.local.example` to `.bashrc.local` and add your local configs
   - Customize SSH configuration in `ssh/config.d/` for your infrastructure

## SSH Configuration

The `ssh/` templates are sanitized examples for structure only:
- They do not contain real infrastructure details
- No private keys or sensitive host data included
- Use `config.d/` subdirectory for organizing host configurations by organization or role

## Skills

This repository includes development skills and best practices sourced from [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills.git). The `.cursor/skills/` directory contains structured guidance on:
- API and Interface Design
- Testing and Quality
- CI/CD and Automation
- Code Review and Documentation
- Performance and Security
- And more...

## License

These are personal dotfiles and skills. Feel free to reference or adapt for your own setup.

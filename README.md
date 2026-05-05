# dot-files

Minimal, versioned dotfiles for my Linux setup.

## Structure

```text
.
├── bash/
│   ├── .bash_aliases
│   ├── .bashrc
│   ├── .bashrc.local.example
│   └── .profile
├── config/
│   ├── btop/
│   │   └── btop.conf
│   └── htop/
│       └── htoprc
├── git/
│   └── .gitconfig
├── ssh/
│   ├── .gitignore
│   ├── config.example
│   └── config.d/
│       └── organization.example
└── link-dotfiles.sh
```

## Usage

Run:

```bash
./link-dotfiles.sh
```

This script creates symlinks from the files in this repository to the expected paths in `$HOME`.

## SSH Notes

The `ssh/` templates are sanitized examples for structure only.
They do not contain real infrastructure details, private keys, or sensitive host data.

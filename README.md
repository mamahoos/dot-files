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
└── link-dotfiles.sh
```

## Usage

Run:

```bash
./link-dotfiles.sh
```

This script creates symlinks from the files in this repository to the expected paths in `$HOME`.

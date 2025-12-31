# dotfiles

Dotfiles management system for Linux workstations with automated fresh machine setup.

## Quick Start (Fresh Debian 11/12/13)

```bash
# Clone the repository
git clone https://github.com/DukeOfEtiquette/dotfiles.git ~/.everc/dotfiles
cd ~/.everc/dotfiles

# Run bootstrap
./bootstrap.sh --profile rogue
```

The bootstrap script handles everything: packages, shell setup, development tools, and dotfile installation.

## For Existing Systems

If your system is already set up and you just need to install/update dotfiles:

```bash
./updateDotfiles.sh --profile <gomez|rogue|ts3d>
```

## Bootstrap Options

```
./bootstrap.sh --profile <profile> [options]

Options:
  --profile, -p <name>   Profile: rogue, gomez, ts3d (required)
  --yes, -y              Skip prompts (auto-confirm)
  --stage, -s <N>        Start from stage N (0-10)
  --dry-run              Preview without changes
  --reset                Clear state and start fresh
```

## Profiles

| Profile | Description |
|---------|-------------|
| **rogue** | Full Maverick dev environment with build toolchain |
| **ts3d** | TS3D development focus with Docker and git-lfs |
| **gomez** | General workstation setup |

## Documentation

- [Setup Guide](docs/SETUP_GUIDE.md) - Detailed setup walkthrough
- [Troubleshooting](docs/TROUBLESHOOTING.md) - Common issues and solutions
- [Debian Upgrades](docs/UPGRADE_DEBIAN.md) - Version upgrade checklists

## What Gets Installed

The bootstrap script installs (in order):

1. **Core packages** - curl, wget, git, git-lfs
2. **Shell** - zsh, oh-my-zsh
3. **Git config** - user setup, SSH key generation
4. **Dev tools** - cmake, make, gcc, build-essential
5. **Desktop** - i3, xfce4-terminal, utilities
6. **Node.js** - via nvm
7. **Docker** - Docker CE with user group setup
8. **Apps** - Chrome, VSCode, Discord
9. **Dotfiles** - symlinks and configs via updateDotfiles.sh

## Post-Installation

After bootstrap completes:

1. **Log out and back in** - Required for docker group and zsh
2. **Add SSH key to GitHub** - `cat ~/.ssh/id_ed25519.pub`
3. **Update i3status config** - Set correct network interface names
4. **Enable VS Code Settings Sync**

## Secrets Management

Secrets are NOT stored in this repository. After setup:

1. Copy the template: `cp secrets/.env.example secrets/.env`
2. Edit with your credentials
3. Secrets load automatically via `secrets.sh`

## Directory Structure

```
dotfiles/
├── bootstrap.sh              # Entry point for fresh installs
├── updateDotfiles.sh         # Dotfile symlink/copy installer
├── setup/                    # Modular setup scripts
│   ├── lib/                  # Shared functions
│   ├── manifests/            # Package lists
│   └── 00-10-*.sh           # Stage scripts
├── profiles/                 # Machine-specific configs
│   ├── rogue/
│   ├── ts3d/
│   ├── gomez/
│   └── shared/
├── docs/                     # Documentation
└── secrets/                  # Gitignored credentials
```

## Useful Commands

```bash
# Preview bootstrap without changes
./bootstrap.sh --profile rogue --dry-run

# Resume from a specific stage
./bootstrap.sh --profile rogue --stage 5

# Non-interactive install
./bootstrap.sh --profile rogue --yes

# Update dotfiles (existing system)
./updateDotfiles.sh --profile rogue

# Find wifi interface for i3status
iw dev | grep Interface
```

## License

Personal dotfiles repository.

# Amplifier Setup (`amp`)

**A transparent wrapper for Claude Code that automatically manages the [Amplifier](https://github.com/microsoft/amplifier) development environment.**

## What is `amp`?

`amp` is a command that you use **exactly like `claude`**, but with all the amplifier complexity handled automatically behind the scenes.

### The Problem

Setting up and maintaining the amplifier environment involves many manual steps:
- Cloning the amplifier repository
- Running `make install` after every clone/update
- Activating the virtual environment
- Providing workspace context to Claude Code
- Managing updates

This creates friction, especially for non-technical users.

### The Solution

`amp` is a **direct replacement for the `claude` command** that:
- ✅ Installs amplifier automatically on first run
- ✅ Updates amplifier daily (when needed)
- ✅ Activates the virtual environment automatically
- ✅ Provides proper workspace context to Claude Code
- ✅ Passes through all `claude` arguments transparently

**You just type `amp` instead of `claude` - that's it.**

## Installation

### Prerequisites

Before installing `amp`, ensure you have:
- **git** - [Installation](https://git-scm.com/downloads)
- **make** - Usually pre-installed on macOS/Linux
- **python3** - [Installation](https://www.python.org/downloads/)
- **uv** - [Installation](https://docs.astral.sh/uv/getting-started/installation/)
- **claude** - [Installation](https://docs.anthropic.com/en/docs/claude-code/install)

### Quick Install

**Copy and paste this into your terminal:**

```bash
gh repo view microsoft/amplifier-setup --raw install.sh | bash
```

Or using curl:

```bash
curl -fsSL https://raw.githubusercontent.com/microsoft/amplifier-setup/main/install.sh | bash
```

This will:
1. Download `amp.sh` to `~/.amp/`
2. Add it to your `~/.bashrc` and `~/.zshrc`
3. Make it available immediately in your current shell

**That's it!** After installation completes, just type `amp` to get started.

### Manual Install

1. Download `amp.sh`:
```bash
mkdir -p ~/.amp
curl -fsSL https://raw.githubusercontent.com/microsoft/amplifier-setup/main/amp.sh -o ~/.amp/amp.sh
chmod +x ~/.amp/amp.sh
```

2. Add to your shell RC file (`~/.bashrc` or `~/.zshrc`):
```bash
echo 'source ~/.amp/amp.sh' >> ~/.bashrc  # or ~/.zshrc
```

3. Reload your shell:
```bash
source ~/.bashrc  # or source ~/.zshrc
```

## Usage

### Basic Usage

Use `amp` exactly like you would use `claude`:

```bash
# Start Claude Code in current directory
amp

# Run with a prompt
amp "implement feature X"

# Pass any claude arguments
amp --help
amp --model opus
amp "analyze this code" --add-dir ../other-project
```

### First Run

On your first `amp` command, it will automatically:
1. Check that prerequisites are installed
2. Clone the amplifier repository to `~/amplifier`
3. Run `make install` to set up dependencies
4. Launch Claude Code with proper workspace context

This takes about 2-5 minutes depending on your network speed.

### Subsequent Runs

After the first run, `amp` is fast:
- Checks for updates once per 24 hours
- If updates are available, pulls and reinstalls automatically
- Otherwise, launches immediately

## How It Works

### Workspace Pattern

When you run `amp` from any directory, it automatically provides Claude Code with workspace context:

```
I'm working on the {project-name} project.
The project is located at {current-directory}.
The ~/amplifier directory is just the dev environment.

Please read @{current-directory}/CLAUDE.md for project-specific guidance.

Whenever we execute any tools, we should assume {current-directory} is the root directory.
```

This tells Claude Code:
- What project you're working on
- Where the project is located
- To look for `CLAUDE.md` for project-specific instructions
- To use your current directory as the working directory

### File Structure

```
~/.amp/                 # State directory
├── amp.sh              # The amp function (installed by install.sh)
├── .amp_ready          # Flag: bootstrap completed
├── .amp_last_check     # Timestamp of last update check
└── .amp.log            # Operation log for troubleshooting

~/amplifier/            # Amplifier repository (cloned on first run)
├── .venv/              # Python virtual environment
├── Makefile            # Build system
├── amplifier/          # Amplifier modules
└── ...
```

## Configuration

### Environment Variables

- `AMP_HOME` - Override state directory (default: `~/.amp`)
- `AMP_AMPLIFIER_DIR` - Override amplifier clone location (default: `~/amplifier`)

Example:
```bash
export AMP_HOME="$HOME/.my-amp-state"
export AMP_AMPLIFIER_DIR="$HOME/my-amplifier"
amp
```

### Update Frequency

By default, `amp` checks for updates once per 24 hours. To force an update check:

```bash
rm ~/.amp/.amp_last_check
amp
```

## Troubleshooting

### Check the Log

If something goes wrong, check the log:

```bash
tail -f ~/.amp/.amp.log
```

### Force Reinstall

If the amplifier installation is corrupted:

```bash
rm ~/.amp/.amp_ready
amp  # Will trigger full bootstrap
```

### Complete Reinstall

To start from scratch:

```bash
rm -rf ~/.amp ~/amplifier
amp  # Will re-clone and install everything
```

### Common Issues

#### "Missing required tools"

Install the missing prerequisites:
- **git**: https://git-scm.com/downloads
- **make**: `xcode-select --install` (macOS) or via package manager (Linux)
- **python3**: https://www.python.org/downloads/
- **uv**: https://docs.astral.sh/uv/getting-started/installation/
- **claude**: https://docs.anthropic.com/en/docs/claude-code/install

#### "Virtual environment not found"

The installation may have been interrupted:

```bash
rm ~/.amp/.amp_ready
amp  # Will retry installation
```

#### "Failed to pull updates"

Network issue or local changes in amplifier repo:

```bash
cd ~/amplifier
git status  # Check for local changes
git reset --hard origin/main  # Reset to clean state
```

## Uninstall

To remove `amp`:

```bash
# Remove the amp function from shell RC files
sed -i.bak '/# Amplifier (amp command)/d' ~/.bashrc
sed -i.bak '/source.*amp.sh/d' ~/.bashrc
sed -i.bak '/# Amplifier (amp command)/d' ~/.zshrc
sed -i.bak '/source.*amp.sh/d' ~/.zshrc

# Remove state and amplifier directories
rm -rf ~/.amp ~/amplifier
```

## Platform Support

- ✅ **macOS** (bash & zsh)
- ✅ **Linux** (bash & zsh)
- ⏸️ **Windows** (not yet supported)

## Contributing

See the [amplifier-setup repository](https://github.com/microsoft/amplifier-setup) for contribution guidelines.

## License

This project is licensed under the MIT License.

## Related Projects

- [Amplifier](https://github.com/microsoft/amplifier) - The underlying development environment
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) - Anthropic's AI coding assistant

---

**Made with ❤️ to simplify amplifier setup**

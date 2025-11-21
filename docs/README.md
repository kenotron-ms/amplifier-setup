# amp - Amplifier Setup

> A transparent wrapper for Claude Code that automatically manages the [Amplifier](https://github.com/microsoft/amplifier) development environment.

## Quick Start

**Install in one line:**

```bash
curl -fsSL https://raw.githubusercontent.com/kenotron-ms/amplifier-setup/main/install.sh | bash
```

After installation completes, reload your shell with the command it shows you, then:

```bash
cd ~/your-project
amp
```

**That's it!** Use `amp` exactly like you would use `claude`.

---

## What is amp?

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

---

## Prerequisites

Before installing `amp`, ensure you have:
- **git** - [Installation](https://git-scm.com/downloads)
- **make** - Usually pre-installed on macOS/Linux
- **python3** - [Installation](https://www.python.org/downloads/)
- **uv** - [Installation](https://docs.astral.sh/uv/getting-started/installation/)
- **claude** - [Installation](https://docs.anthropic.com/en/docs/claude-code/install)

---

## First Run Experience

On your first `amp` command, it will automatically:
1. Check that prerequisites are installed
2. Clone the amplifier repository to `~/.amp/main`
3. Run `make install` to set up dependencies
4. Create a workspace worktree for your current directory
5. Launch Claude Code with proper workspace context

This takes about 2-5 minutes depending on your network speed.

---

## Subsequent Runs

After the first run, `amp` is fast:
- Checks for updates once per 24 hours
- If updates are available, pulls and reinstalls (only when dependencies change)
- Otherwise, launches immediately

---

## Platform Support

- ✅ **macOS** (bash & zsh)
- ✅ **Linux** (bash & zsh)
- ⏸️ **Windows** (not yet supported)

---

## Related Projects

- [Amplifier](https://github.com/microsoft/amplifier) - The underlying development environment
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) - Anthropic's AI coding assistant

---

**Made with ❤️ to simplify amplifier setup**

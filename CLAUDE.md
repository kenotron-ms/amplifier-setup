# CLAUDE.md - Amplifier Setup

Project-specific guidance for Claude Code when working in this repository.

## Repository Architecture

### Critical Principle: Amplifier Main Repo is Immutable

**The `amplifier` repo (`microsoft/amplifier` or `~/amplifier`) is NEVER modified.**

All customizations, extensions, and augmentations happen in THIS repo (`amplifier-setup`).

This means:
- **Never** commit changes to the amplifier repo
- **Never** create files in ~/amplifier directly
- **Always** add new agents, commands, hooks, and plugins here in amplifier-setup
- The amplifier repo is treated as a read-only upstream dependency

### Repository Purposes

| Repo | Purpose | Mutability |
|------|---------|------------|
| `amplifier-setup` | Install scripts, customizations, plugins, marketplace | **Mutable** (this repo) |
| `amplifier` | Core amplifier functionality, base agents/commands | **Immutable** (upstream) |

### How Customization Works

1. `amplifier-setup` contains install/update scripts that set up the environment
2. Worktrees are created from the immutable `amplifier` repo
3. This repo's plugins/extensions augment the base functionality
4. The marketplace in this repo references plugins defined here

## Build/Install Commands

- Install amp command: `./install.sh` (or curl from GitHub)
- Create workspace: `amp` (from any project directory)
- List workspaces: `amp workspace list`

## File Organization

```
amplifier-setup/
├── install.sh          # Main installation script
├── amp.sh              # Core amp command
├── amp-workspace.sh    # Workspace management
├── .claude-plugin/     # Plugin marketplace manifest
│   └── marketplace.json
├── plugins/            # Custom plugins (agents, commands, hooks)
└── docs/               # Documentation
```

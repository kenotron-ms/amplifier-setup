# CLAUDE.md - Amplifier Setup

Project-specific guidance for Claude Code when working in this repository.

## CRITICAL: Working Directory Context

**These three points are fundamental to understanding your workspace context:**

1. **The working directory IS the project directory**: `/Users/ken/workspace/amplifier-setup` is the actual project directory where all the user's work lives. This is what matters most.

2. **Git operations focus on the project directory**: All git operations (commits, status, branches, PRs, etc.) should operate on `/Users/ken/workspace/amplifier-setup`, NOT on the amplifier dev environment (`/Users/ken/.amp/w/Users-ken-workspace-amplifier-setup`).

3. **Amplifier dev environment should fade into background**: The amplifier dev environment at `/Users/ken/.amp/w/Users-ken-workspace-amplifier-setup` is supporting infrastructure that should be invisible to the user. When discussing "the project" or "your repository," always refer to `/Users/ken/workspace/amplifier-setup`. The dev environment is just scaffolding—the user's repo is what truly matters.

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
├── ai_context/         # AI context and documentation
│   └── claude_code/    # Claude Code specific docs
└── docs/               # Documentation
```

## Claude Code Extension Reference

For comprehensive documentation on creating and configuring Claude Code extensions, see:

- **@ai_context/claude_code/EXTENSION_MECHANISMS.md** - Complete reference for:
  - Slash commands (frontmatter fields, structure)
  - Subagents and skills
  - Hooks (all types, configuration)
  - Plugins (plugin.json schema)
  - Marketplaces (marketplace.json schema)
  - Common validation errors and fixes

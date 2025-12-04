# Claude Code Plugins

Amplifier-setup includes Claude Code plugins that extend functionality with workflow helpers and integrations.

## What Are Plugins?

Plugins are packaged extensions for Claude Code that add:
- **Slash commands** - Custom workflows triggered with `/command` syntax
- **Integrations** - Connections to external tools and services
- **Workflow automation** - Multi-step processes guided by Claude

## Available Plugins

### Git Plugin

Git workflow helpers for creating PRs and syncing branches with intelligent conflict resolution.

**Commands:**
- `/pull` - Sync your feature branch with latest changes from origin/main
- `/submit-pr` - Submit a pull request from the current branch

**Features:**
- Intelligent conflict resolution with high-level guidance
- Automatic rebase workflow
- Interactive decision-making for conflicts
- GitHub CLI integration for PR creation
- **Automatic documentation compliance** - Discovers and enforces repository standards before PR submission:
  - Discovers standards from `CONTRIBUTING.md`, `MAINTENANCE.md`, `CLAUDE.md`
  - Automatically updates required documentation based on code changes
  - Runs pre-PR checks (linting, testing, type checking)
  - Generates/updates auto-generated files
  - Blocks PR submission if compliance fails
  - Uses general-purpose agent (or specialized `docs-compliance-agent` if available)

[See git plugin documentation →](../plugins/git/README.md)

---

## Plugin Architecture

### How Plugins Work

Plugins are automatically configured when you run `amp` in a project directory:

1. **Marketplace registration** - The `amplifier-setup` marketplace is added to your workspace
2. **Plugin discovery** - Claude Code finds all plugins in the `plugins/` directory
3. **Command availability** - Slash commands become available in your session

### Directory Structure

```
plugins/
└── git/
    ├── .claude-plugin/
    │   └── plugin.json      # Plugin manifest
    ├── commands/
    │   ├── pull.md          # /pull command
    │   └── submit-pr.md     # /submit-pr command
    └── README.md
```

### Project Directory Handling

All plugin commands automatically work in the correct project directory:

- **Default behavior**: Uses `$PWD` (current working directory)
- **Override**: Set `PROJECT_DIR` environment variable
- **Why it matters**: Ensures git commands run in your actual project, not the Claude worktree

**Example from commands:**
```bash
# Commands automatically set this
PROJECT_DIR="${PROJECT_DIR:-$PWD}"
echo "Working in: $PROJECT_DIR"

# Then all operations use it
cd "$PROJECT_DIR"
git status
```

---

## Using Plugins

### Basic Usage

Once `amp` is running, use slash commands:

```bash
# List available commands
/help

# Sync with main branch
/pull

# Create a pull request
/submit-pr
```

### Command Arguments

Some commands accept arguments:

```bash
# Most commands are interactive
/pull
# Claude will guide you through any conflicts

/submit-pr
# Claude will ask for commit message and PR details
```

---

## Plugin Marketplace

### How It Works

The `amplifier-setup` repository is registered as a Claude Code marketplace:

**Configured in:** `~/.amp/w/<workspace>/.claude/settings.local.json`

```json
{
  "extraKnownMarketplaces": {
    "amplifier-setup": {
      "source": {
        "source": "github",
        "repo": "kenotron-ms/amplifier-setup"
      }
    }
  }
}
```

This configuration is automatically added by `amp-workspace.sh` when creating a workspace.

### Updating Plugins

Plugins are updated automatically when you run:

```bash
amp update
```

This updates:
1. The amplifier repository
2. The amp scripts
3. Plugin marketplaces (via Claude Code)

---

## Creating Your Own Plugins

### Plugin Structure

To create a plugin, follow this structure:

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json         # REQUIRED: Plugin manifest
├── commands/               # OPTIONAL: Slash commands
│   ├── command1.md
│   └── command2.md
└── README.md              # RECOMMENDED: Documentation
```

### plugin.json

```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "description": "What your plugin does",
  "author": {
    "name": "Your Name"
  },
  "commands": [
    "./commands/command1.md",
    "./commands/command2.md"
  ]
}
```

### Command Files

Commands are markdown files with instructions for Claude:

```markdown
# Command Name

Brief description of what this command does.

## Important Notes

[Any critical information Claude needs to know]

## Workflow

Follow these steps in order:

### Step 1: [First action]

```bash
# Commands Claude should run
command --flag value
```

[Explanation of what to do with results]

### Step 2: [Next action]

...
```

**Key principles:**
- Write for Claude, not humans
- Be explicit about every step
- Use code blocks for commands to execute
- Explain what to do with results
- Handle error cases

### Example: Simple Command

```markdown
# Hello World

Say hello to the user with their username.

## Workflow

1. Get the current username:
   ```bash
   whoami
   ```

2. Greet the user by name:
   - Say: "Hello, [username]! Welcome to the plugin demo."
   - Add a fun fact about their shell environment

## Error Handling

If `whoami` fails, use "friend" as fallback.
```

---

## Advanced Topics

### Environment Variables

Commands can access these environment variables:

- `PWD` - Current working directory (actual project)
- `PROJECT_DIR` - Override for project directory (if set)
- `HOME` - User's home directory
- `CLAUDE_PROJECT_DIR` - Claude worktree directory (not for git operations!)

**Best practice:** Use `PROJECT_DIR="${PROJECT_DIR:-$PWD}"` for directory detection

### Using Other Tools

Commands can use any Claude Code tools:

- `Bash` - Run shell commands
- `Read` - Read file contents
- `Edit` / `Write` - Modify files
- `Grep` / `Glob` - Search codebase
- `AskUserQuestion` - Interactive prompts
- `Task` - Launch subagents

**Specify in frontmatter:**
```yaml
---
description: Your command description
allowed-tools: Bash, Read, AskUserQuestion
---
```

### Complex Workflows

For multi-step workflows:

1. **Break into numbered steps** - Clear sequential flow
2. **Handle errors explicitly** - Provide abort/retry options
3. **Use AskUserQuestion** - Get user input at decision points
4. **Show progress** - Keep user informed of what's happening
5. **Report results** - Summarize what was accomplished

---

## Troubleshooting

### Plugin Not Loading

**Symptom:** `/help` doesn't show your commands

**Solutions:**
1. Check `plugin.json` syntax is valid JSON
2. Verify command paths start with `./`
3. Ensure `.claude-plugin/` directory name is exact
4. Restart Claude Code session

### Command Not Working

**Symptom:** Command runs but fails

**Check:**
1. `PROJECT_DIR` is set correctly
2. Required tools are available (git, gh, etc.)
3. Command markdown has proper bash code blocks
4. Error messages in Claude's output

### Marketplace Not Updating

**Symptom:** Changes to plugins don't appear

**Fix:**
```bash
# Update marketplace
claude plugin marketplace update

# Or via amp
amp update
```

---

## Reference Documentation

For complete Claude Code extension mechanisms:
- [Extension Mechanisms Reference](../ai_context/claude_code/EXTENSION_MECHANISMS.md) - Complete guide
- [Hooks Reference](../ai_context/claude_code/CLAUDE_CODE_HOOKS.md) - Hook system
- [SDK Documentation](../ai_context/claude_code/CLAUDE_CODE_SDK.md) - Claude Agent SDK

---

## Contributing Plugins

To contribute a plugin to amplifier-setup:

1. Create plugin in `plugins/` directory
2. Follow structure guidelines above
3. Add README.md with usage examples
4. Test thoroughly with `amp`
5. Submit PR to [amplifier-setup](https://github.com/kenotron-ms/amplifier-setup)

---

**Made with ❤️ to enhance Claude Code workflows**

# Claude Code Extension Mechanisms - Complete Reference

This document provides comprehensive documentation on all Claude Code extension mechanisms including plugins, marketplaces, commands, hooks, skills, and subagents.

---

## Table of Contents

1. [Slash Commands](#1-slash-commands)
2. [Subagents](#2-subagents)
3. [Hooks](#3-hooks)
4. [Skills](#4-skills)
5. [Plugins](#5-plugins)
6. [Marketplaces](#6-marketplaces)
7. [How They Relate](#7-how-they-relate-to-each-other)
8. [Settings.json Reference](#8-settingsjson---complete-reference)
9. [Quick Reference Table](#9-quick-reference-table)

---

## 1. SLASH COMMANDS

### What They Are
Slash commands are custom extensions that appear as `/commandname` in Claude Code. They extend functionality by allowing you to trigger predefined workflows, integrations, or complex operations.

### File Format & Location
- **Location**: `.claude/commands/` directory
- **Format**: Markdown files with YAML frontmatter
- **File naming**: `command-name.md` (converts to `/command-name`)
- **Nested commands**: Use subdirectories (e.g., `.claude/commands/ddd/1-plan.md` = `/ddd:1-plan`)

### Frontmatter Fields (ALL AVAILABLE)

```yaml
---
# REQUIRED FIELDS
description: String description of what the command does (appears in /help)

# OPTIONAL FIELDS
category: String for organizing commands (e.g., "version-control-git", "planning", "code-review")
allowed-tools: Comma-separated list of tools the command can use
               Options: Bash, Read, Glob, Grep, Write, Edit, MultiEdit,
                       WebFetch, WebSearch, TodoWrite, Task,
                       mcp__* (MCP servers), etc.
argument-hint: Placeholder text showing what arguments the command expects
               Appears in suggestions to user
---
```

### Markdown Content Structure

```markdown
---
description: Create well-formatted git commits with conventional commit messages
category: version-control-git
allowed-tools: Bash, Read, Glob
---

# Claude Command: Commit

[Markdown content - description of what the command does]

## Usage

/commit

[Detailed description of behavior and steps]

## Additional Guidance

$ARGUMENTS
```

**Key Elements**:
- `# Claude Command: [Name]` - Header (convention)
- `$ARGUMENTS` - Placeholder that gets replaced with user's arguments
- Can include tool recommendations and step-by-step instructions
- Can reference external docs with `@` syntax

### Example Command

```yaml
---
description: Create well-formatted git commits with conventional commit messages
category: version-control-git
allowed-tools: Bash, Read, Glob
---

# Claude Command: Commit

This command helps you create well-formatted commits with conventional commit messages.

## Usage

To create a commit, just type:

/commit

Or with options:

/commit --no-verify

## What This Command Does

1. Unless specified with `--no-verify`, automatically runs pre-commit checks
2. Checks which files are staged with `git status`
3. Creates commit with conventional message format
```

---

## 2. SUBAGENTS

### What They Are
Subagents are specialized AI agents that are spawned via the `Task` tool to handle specific subtasks. They have their own context, capabilities, and personas.

### File Format & Location
- **Location**: `.claude/agents/` directory
- **Format**: Markdown files with YAML frontmatter
- **File naming**: `agent-name.md` (used as `name` in frontmatter)
- **One agent per file**

### Frontmatter Fields (ALL AVAILABLE)

```yaml
---
# REQUIRED FIELDS
name: String identifier for the agent (matches file purpose)
description: Comprehensive description of what the agent does
             Should include examples of when to use it
             Can include <example> blocks showing usage patterns

# OPTIONAL FIELDS
model: inherit | specific-model-id
       inherit = uses same model as parent Claude Code session
       specific-model-id = "claude-sonnet-4-5-20250929" etc.
---
```

### Markdown Content Structure

```markdown
---
name: zen-architect
description: Use this agent PROACTIVELY for code planning, architecture design, and review tasks...

<example>
Context: User needs a new feature
user: "Add a caching layer to improve API performance"
assistant: "I'll use the zen-architect agent to analyze requirements and design the caching architecture"
<commentary>
New feature requests trigger ANALYZE mode to break down the problem and create implementation specs.
</commentary>
</example>

model: inherit
---

# Agent Name

[Main agent persona and instructions - can be extensive]

## Operating Modes

[Detailed behavior descriptions]

## Core Capabilities

[What the agent does well]
```

### Invocation

```
I'll use the zen-architect agent to analyze requirements and design the solution.
```

Subagents are invoked via the Task tool with `subagent_type` parameter.

---

## 3. HOOKS

### What They Are
Hooks are shell commands that execute automatically in response to Claude Code events. They enable automation, logging, validation, and custom workflows.

### Configuration Location
- **File**: `.claude/settings.json`
- **Key**: `"hooks"` at root level
- **Structure**: Object mapping hook types to arrays of hook configurations

### Hook Types (ALL AVAILABLE)

| Hook Type | When Triggered | Use Cases |
|-----------|----------------|-----------|
| `SessionStart` | When Claude Code session begins | Initialize environment, load context |
| `SessionEnd` | When Claude Code session ends | Cleanup, save state |
| `Stop` | When user stops the current task | Cleanup resources |
| `SubagentStop` | When a subagent stops | Cleanup subagent resources |
| `PreToolUse` | Before a tool executes | Log tool usage, validate permissions |
| `PostToolUse` | After a tool executes | Process results, update state |
| `Notification` | When system sends notification | Custom notification handling |
| `PreCompact` | Before compacting context | Save session state |

### Hook Configuration Schema

```json
{
  "hooks": {
    "HookType": [
      {
        "matcher": "string-pattern | *",
        "hooks": [
          {
            "type": "command",
            "command": "path/to/script.py",
            "timeout": 10000,
            "env": { "KEY": "value" }
          }
        ]
      }
    ]
  }
}
```

### Hook Configuration Fields

```json
{
  "type": "command",           // REQUIRED: currently only "command" supported
  "command": "$CLAUDE_PROJECT_DIR/.claude/tools/script.py",
                               // REQUIRED: path to executable
                               // Can use env var: $CLAUDE_PROJECT_DIR, $HOME, etc.
  "timeout": 10000,            // OPTIONAL: milliseconds before timeout
  "env": { "KEY": "value" },   // OPTIONAL: environment variables to pass
  "matcher": "Tool1|Tool2"     // OPTIONAL: filter by tool name (PostToolUse only)
}
```

### Matcher Patterns

```json
// Match specific tool
"matcher": "Task"

// Match multiple tools with regex
"matcher": "Edit|MultiEdit|Write"

// Match all tools
"matcher": "*"
```

### Example Configuration

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/tools/hook_session_start.py",
            "timeout": 10000
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|MultiEdit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/tools/on_code_change_hook.sh"
          }
        ]
      }
    ]
  }
}
```

---

## 4. SKILLS

### What They Are
Skills are similar to subagents but optimized for specific, narrowly-scoped tasks. They're lightweight specializations for focused work.

### Differences from Commands & Subagents

| Feature | Skills | Commands | Subagents |
|---------|--------|----------|-----------|
| Scope | Narrow, focused | Workflow/UI | Broad expertise |
| Invocation | Via Task tool | `/command` syntax | Via Task tool |
| State | Minimal | Per-session | Full context |
| Setup | Light | Light | Heavy |

### Implementation
Skills are implemented as specialized subagents with focused personas and narrow scope. They use the same file format as subagents but with more focused descriptions.

---

## 5. PLUGINS

### What They Are
Plugins extend Claude Code with new tools, integrations, and capabilities. They're packages that add functionality to the core system.

### File Structure
```
my-plugin/
├── .claude-plugin/
│   └── plugin.json        # Plugin manifest
├── commands/              # Slash commands (optional)
│   ├── command1.md
│   └── command2.md
└── README.md
```

### plugin.json Schema (Complete)

```json
{
  "name": "string",                    // REQUIRED: unique identifier
  "version": "semver",                 // REQUIRED: "1.0.0"
  "description": "string",             // REQUIRED: what plugin does
  "author": {                          // REQUIRED: must be object, not string
    "name": "string",
    "email": "string",                 // OPTIONAL
    "url": "string"                    // OPTIONAL
  },
  "commands": [                        // REQUIRED: array of command file paths
    "./commands/command1.md",          // Must start with "./"
    "./commands/command2.md"           // Must end with ".md"
  ],
  "license": "string",                 // OPTIONAL: license type
  "homepage": "url",                   // OPTIONAL: plugin website
  "repository": "url",                 // OPTIONAL: source repo
  "keywords": ["string"],              // OPTIONAL: searchable tags
  "categories": ["string"]             // OPTIONAL: plugin categories
}
```

### Important Schema Notes

1. **`author` must be an object**, not a string:
   ```json
   // WRONG
   "author": "kenotron-ms"

   // CORRECT
   "author": { "name": "kenotron-ms" }
   ```

2. **`commands` must be an array of paths**:
   ```json
   // WRONG
   "commands": "../commands"

   // CORRECT
   "commands": [
     "./commands/git-pull.md",
     "./commands/submit-pr.md"
   ]
   ```

3. **Command paths must**:
   - Start with `./`
   - End with `.md`

---

## 6. MARKETPLACES

### What They Are
Marketplaces are repositories of plugins that can be discovered and installed. They enable sharing and distribution of Claude Code extensions.

### File Structure
```
marketplace-repo/
├── .claude-plugin/
│   └── marketplace.json   # Marketplace manifest
├── plugins/
│   └── plugin-name/
│       ├── .claude-plugin/
│       │   └── plugin.json
│       └── commands/
│           └── command.md
└── README.md
```

### marketplace.json Schema

```json
{
  "name": "string",                    // REQUIRED: marketplace name
  "owner": {                           // REQUIRED: marketplace owner
    "name": "string",
    "url": "string"                    // OPTIONAL
  },
  "metadata": {                        // OPTIONAL
    "description": "string",
    "version": "semver",
    "pluginRoot": "./plugins"          // Where plugins are located
  },
  "plugins": [                         // REQUIRED: list of available plugins
    {
      "name": "string",                // REQUIRED: plugin identifier
      "source": "./plugins/name",      // REQUIRED: path to plugin
      "description": "string",         // REQUIRED
      "version": "semver",             // REQUIRED
      "author": {                      // REQUIRED: must be object
        "name": "string"
      },
      "keywords": ["string"]           // OPTIONAL
    }
  ]
}
```

### Registering a Marketplace in settings.json

```json
{
  "extraKnownMarketplaces": {
    "marketplace-name": {
      "source": {
        "source": "github",
        "repo": "owner/repo-name"
      }
    }
  }
}
```

### Marketplace Source Types

```json
// GitHub source
{
  "source": "github",
  "repo": "owner/repo-name",
  "path": "plugins"              // OPTIONAL: subdirectory
}

// Local file source
{
  "source": "local",
  "path": "/path/to/marketplace"
}
```

---

## 7. HOW THEY RELATE TO EACH OTHER

### Relationship Diagram

```
User Request
    │
    ├─→ /slash-command (executes)
    │       ├─→ Can invoke Task → Subagent/Skill
    │       ├─→ Can use Hooks to trigger events
    │       └─→ Can invoke Tools (built-in or from Plugins)
    │
Plugin (extends system)
    ├─→ Adds new Commands (/command)
    └─→ Distributed via Marketplace

Marketplace (distributes)
    └─→ Makes plugins discoverable

Hooks (reactive)
    ├─→ Listen for SessionStart, PostToolUse, etc.
    └─→ Can invoke scripts/subagents

Subagents/Skills (specialized)
    ├─→ Invoked via Task tool
    └─→ Can use any available tools
```

### Common Patterns

**Pattern 1: Command → Subagent → Tools**
```
/review-code
  → Invokes task with zen-architect
    → Reads files with Read tool
    → Greps for patterns with Grep tool
    → Reports findings
```

**Pattern 2: Hook → Script → Validation**
```
PostToolUse (Edit detected)
  → Triggers hook script
    → Runs validation
    → Returns result
```

**Pattern 3: Plugin → Command → Workflow**
```
Plugin installs /git-flow commands
  → /git-pull syncs with upstream
  → /submit-pr creates PR
```

---

## 8. SETTINGS.JSON - COMPLETE REFERENCE

```json
{
  "model": "sonnet",                   // Which Claude model to use

  "permissions": {                     // Tool access control
    "allow": ["Tool1", "Tool2"],       // Allowed tools
    "deny": [],                        // Explicitly denied tools
    "defaultMode": "bypassPermissions",
                                       // askPermissions | bypassPermissions
    "additionalDirectories": [         // Extra dirs to access
      ".data", ".vscode", ".claude"
    ]
  },

  "enableAllProjectMcpServers": false, // Auto-enable MCP servers
  "enabledMcpjsonServers": [           // Specific enabled MCP servers
    "browser-use",
    "deepwiki"
  ],

  "hooks": {                           // Event-driven automation
    "HookType": [
      {
        "matcher": "pattern",
        "hooks": [
          {
            "type": "command",
            "command": "path/to/script",
            "timeout": 10000
          }
        ]
      }
    ]
  },

  "extraKnownMarketplaces": {          // Additional plugin sources
    "marketplace-name": {
      "source": {
        "source": "github",
        "repo": "owner/repo"
      }
    }
  }
}
```

---

## 9. QUICK REFERENCE TABLE

| Mechanism | File Type | Location | Invocation | Best For |
|-----------|-----------|----------|------------|----------|
| Command | Markdown + YAML | `.claude/commands/` | `/name` | Sequential workflows |
| Subagent | Markdown + YAML | `.claude/agents/` | Task tool | Complex domains |
| Skill | Markdown + YAML | `.claude/agents/` | Task tool | Narrow specialization |
| Hook | JSON config | `.claude/settings.json` | Auto-triggered | Reactive automation |
| Plugin | JSON + commands | Via marketplace | Install + use | Distributable extensions |
| Marketplace | JSON | Remote/local | Discovery | Plugin sharing |

---

## Common Validation Errors

### Plugin Schema Errors

**Error**: `author: Expected object, received string`
```json
// Fix: Change from string to object
"author": { "name": "your-name" }
```

**Error**: `commands: Invalid input: must start with "./"`
```json
// Fix: Use explicit paths starting with ./
"commands": ["./commands/my-command.md"]
```

**Error**: `commands: Invalid input: must end with ".md"`
```json
// Fix: Ensure all command paths end with .md
"commands": ["./commands/my-command.md"]
```

---

## Resources

- [Plugin Marketplaces - Claude Code Docs](https://code.claude.com/docs/en/plugin-marketplaces)
- [Customize Claude Code with Plugins - Anthropic](https://www.anthropic.com/news/claude-code-plugins)

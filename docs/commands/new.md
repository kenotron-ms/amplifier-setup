# amp new

Create a new Amplifier project with pre-configured setup.

## Usage

```bash
# Initialize current directory as an Amplifier project
amp new

# Create a new project directory
amp new my-project

# Create nested project
amp new ~/projects/my-app
```

## What It Creates

1. **CLAUDE.md** - Project configuration with Flow-Driven Development guidance
2. **Git repository** - Initialized automatically (if git is available)
3. **GitHub repository** - Optionally creates remote repo (if gh CLI is available)

## Interactive Flow

```bash
$ amp new my-app

🚀 Creating new Amplifier project: my-app
   Location: /Users/ken/projects/my-app
📁 Created directory
📄 Created CLAUDE.md
📦 Initialized git repository

🐙 Create GitHub repository?
   Suggested: username/my-app
   Create? [y/N]: y
✅ Created GitHub repository: username/my-app
📤 Pushing initial commit...
✅ Pushed to GitHub

✨ Project ready!

Next steps:
  cd my-app
  # Edit CLAUDE.md with your project details
  amp
```

## CLAUDE.md Content

The generated `CLAUDE.md` includes:
- Reference to Flow-Driven Development philosophy
- Guidance for `/ultrathink-task` command
- Sections for project-specific build/test/style guidelines
- Links to amplifier resources

## Current Directory Mode

When run without arguments, `amp new` initializes the current directory:

```bash
cd ~/existing-project
amp new

🚀 Initializing Amplifier project: existing-project
   Location: /Users/ken/existing-project
📄 Created CLAUDE.md
📦 Initialized git repository
...
```

## Requirements

**Optional (for full functionality):**
- **git** - For repository initialization
- **gh CLI** - For GitHub repository creation
  - Must be authenticated: `gh auth login`

Without these tools, `amp new` will:
- Skip git initialization with a helpful message
- Skip GitHub creation with installation instructions

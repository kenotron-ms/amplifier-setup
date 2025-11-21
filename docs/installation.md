# Installation

## Quick Install

**Copy and paste this into your terminal:**

```bash
curl -fsSL https://raw.githubusercontent.com/kenotron-ms/amplifier-setup/main/install.sh | bash
```

The installer will:
1. Download latest `amp.sh` and related scripts to `~/.amp/`
2. Add it to your `~/.bashrc` and `~/.zshrc`
3. Make it available immediately in your current shell

## After Installation

Copy and paste this command to reload your shell (works for bash and zsh):

```bash
source ~/.${SHELL##*/}rc
```

Then you're ready to use `amp`!

## Verification

After reloading your shell, verify the installation:

```bash
type amp
```

You should see: `amp is a function`

## Next Steps

Navigate to any project directory and run:

```bash
amp
```

On first run, amp will automatically bootstrap the amplifier environment (takes 2-5 minutes).

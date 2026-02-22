# Quick Start: Extensible Dotfiles

**TL;DR:** Use the base dotfiles repo + add your own dependencies **without forking**.

---

## 🚀 3 Ways to Extend (Pick One)

### Option 1: Environment Variables (Easiest!)

```bash
# Set env vars, then run dotfiles
export DOTFILES_EXTRA_PIP="pandas numpy torch"
export DOTFILES_EXTRA_APT="vim tmux htop"

coder dotfiles https://github.com/ly2xxx/coder-dotfiles-example
```

**Best for:** Quick additions, team defaults in Coder template

---

### Option 2: Override Files (Most Flexible)

```bash
# Create override directory
mkdir -p ~/.dotfiles-extra

# Copy example for your use case
cp examples/data-science-setup/* ~/.dotfiles-extra/

# Customize as needed
nano ~/.dotfiles-extra/requirements.txt

# Run dotfiles (it will auto-detect override files)
coder dotfiles https://github.com/ly2xxx/coder-dotfiles-example
```

**Best for:** Complex setups, multiple tool categories

---

### Option 3: Command Line (Most Explicit)

```bash
# Download the extensible install script
cd coder-dotfiles-example

# Run with custom parameters
./install-extensible.sh \
  --pip-requirements ~/my-requirements.txt \
  --apt-packages "vim tmux htop" \
  --post-script ~/custom-setup.sh
```

**Best for:** Testing, one-off installs

---

## 📦 Pre-Made Examples

Copy and customize from `examples/`:

### Data Science
```bash
cp -r examples/data-science-setup ~/.dotfiles-extra
```
Includes: pandas, numpy, scikit-learn, torch, jupyter

### Web Development
```bash
cp -r examples/web-dev-setup ~/.dotfiles-extra
```
Includes: django, fastapi, react, typescript, postgresql

### DevOps
```bash
cp -r examples/devops-setup ~/.dotfiles-extra
```
Includes: kubectl, helm, terraform, ansible, docker

---

## 🎯 Common Use Cases

### Use Case 1: Team with Individual Customization

**Team Lead** sets base in Coder template:
```hcl
# main.tf
resource "coder_agent" "main" {
  env = {
    DOTFILES_EXTRA_PIP = "black flake8 pytest"
  }
}
```

**Individual developer** adds personal tools:
```bash
# In workspace
export DOTFILES_EXTRA_PIP="$DOTFILES_EXTRA_PIP pandas torch"
```

---

### Use Case 2: Multiple Workspaces, Same Setup

Create `~/.dotfiles-extra/` once, works across all workspaces:

```bash
# One-time setup
mkdir -p ~/.dotfiles-extra
cat > ~/.dotfiles-extra/requirements.txt <<EOF
your-favorite-packages
EOF

# Use in any workspace
coder dotfiles https://github.com/ly2xxx/coder-dotfiles-example
```

---

### Use Case 3: Quick Test

```bash
# Test with minimal setup
export DOTFILES_SKIP_DEFAULT="true"  # Skip base installs
export DOTFILES_EXTRA_PIP="requests"
export DOTFILES_VERBOSE="true"  # See what's happening

./install-extensible.sh
```

---

## 🔍 What Gets Installed?

### Default (if not skipped)
- ✅ Gemini CLI
- ✅ Playwright + Chromium
- ✅ xvfb (virtual display)
- ✅ Personal repo (ly2xxx)
- ✅ Custom .bashrc and .gitconfig

### Your Extensions
- ✅ Environment variable packages
- ✅ Override files from `~/.dotfiles-extra/`
- ✅ Command line parameters
- ✅ Custom scripts

---

## 📝 Override File Reference

Place these in `~/.dotfiles-extra/`:

| File | Purpose | Example |
|------|---------|---------|
| `requirements.txt` | Python pip packages | `pandas==2.0.0` |
| `packages.txt` | System apt packages | `vim` |
| `npm-packages.txt` | Node.js packages | `typescript` |
| `custom.sh` | Shell script (runs last) | Install custom tools |
| `env.sh` | Environment variables | `export MY_VAR=value` |

---

## 🧪 Testing Your Setup

### Local Test
```bash
# Clone the repo
git clone https://github.com/ly2xxx/coder-dotfiles-example.git
cd coder-dotfiles-example

# Create test override
mkdir -p ~/.dotfiles-extra
echo "requests" > ~/.dotfiles-extra/requirements.txt

# Run install
./install-extensible.sh --verbose

# Verify
python3 -c "import requests; print('✅ requests installed!')"
```

### Coder Test
```bash
# Create test workspace
coder create test-dotfiles \
  --parameter dotfiles_url="https://github.com/ly2xxx/coder-dotfiles-example"

# SSH in and check
coder ssh test-dotfiles
python3 -c "import google.generativeai; print('✅ Gemini OK')"
```

---

## ⚙️ Environment Variables Reference

| Variable | Description | Example |
|----------|-------------|---------|
| `DOTFILES_EXTRA_PIP` | Extra pip packages | `"pandas numpy"` |
| `DOTFILES_EXTRA_APT` | Extra apt packages | `"vim tmux"` |
| `DOTFILES_EXTRA_NPM` | Extra npm packages | `"typescript"` |
| `DOTFILES_CUSTOM_REPO` | Clone this git repo | `"https://github.com/user/scripts"` |
| `DOTFILES_CUSTOM_SCRIPT` | Run this script URL | `"https://example.com/setup.sh"` |
| `DOTFILES_SKIP_DEFAULT` | Skip defaults | `"true"` |
| `DOTFILES_VERBOSE` | Debug output | `"true"` |

---

## 🎓 Next Steps

1. ✅ Pick an extension method (env vars recommended)
2. ✅ Copy an example or create your own
3. ✅ Test locally first
4. ✅ Apply to Coder workspace
5. ✅ Share your setup with the team!

---

## 📚 Full Documentation

- **[EXTENSIBILITY-GUIDE.md](EXTENSIBILITY-GUIDE.md)** - Complete guide with all patterns
- **[examples/](examples/)** - Pre-made configurations for common stacks
- **[install-extensible.sh](install-extensible.sh)** - The enhanced install script

---

## 💡 Pro Tips

**Tip 1:** Use env vars in Coder template for team defaults
```hcl
env = {
  DOTFILES_EXTRA_PIP = "black flake8 pytest mypy"
}
```

**Tip 2:** Keep override files in a private gist
```bash
# Download from gist
curl https://gist.githubusercontent.com/user/ID/raw/requirements.txt \
  -o ~/.dotfiles-extra/requirements.txt
```

**Tip 3:** Version control your overrides
```bash
# Separate repo for your personal overrides
git clone https://github.com/yourusername/my-dotfiles-overrides.git ~/.dotfiles-extra
```

**Tip 4:** Use `--verbose` to debug
```bash
export DOTFILES_VERBOSE="true"
./install-extensible.sh
```

---

## ❓ FAQ

**Q: Do I need to fork the repo?**  
A: No! That's the whole point. Use env vars or override files.

**Q: Can I skip the default installations?**  
A: Yes! Set `DOTFILES_SKIP_DEFAULT="true"`

**Q: What if I need both pip and apt packages?**  
A: Combine methods! Use env vars + override files together.

**Q: How do I update my custom packages?**  
A: Edit your override files or env vars, then re-run dotfiles.

**Q: Can I use this with existing Coder templates?**  
A: Yes! Just point `dotfiles_url` to this repo.

---

**Questions?** Read [EXTENSIBILITY-GUIDE.md](EXTENSIBILITY-GUIDE.md) or open an issue!

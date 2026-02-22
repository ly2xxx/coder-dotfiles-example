# Dotfiles Extensibility Guide

**Problem:** You want to use a base dotfiles repo but add your own custom dependencies without maintaining a fork.

**Solution:** Multiple extension patterns that let you inject custom configs, dependencies, and scripts.

---

## 🎯 Extension Patterns (Best to Worst)

### ✅ Pattern 1: Environment Variables (Recommended)
**Best for:** Adding custom dependencies, repos, or scripts without forking

```bash
# In Coder workspace or ~/.bashrc
export DOTFILES_EXTRA_PIP="pandas numpy scikit-learn"
export DOTFILES_EXTRA_APT="vim tmux htop"
export DOTFILES_CUSTOM_REPO="https://github.com/yourusername/my-custom-scripts.git"
export DOTFILES_CUSTOM_SCRIPT="https://raw.githubusercontent.com/yourusername/setup/main/custom.sh"

# Then run dotfiles
coder dotfiles https://github.com/ly2xxx/coder-dotfiles-example
```

**Pros:**
- ✅ No forking needed
- ✅ Easy to update base dotfiles
- ✅ Can set in Coder template for team-wide defaults
- ✅ Per-user customization via env vars

**Cons:**
- ❌ Need to set env vars before running dotfiles

---

### ✅ Pattern 2: Local Override Files
**Best for:** Per-user customization in existing workspaces

Create optional files in your home directory:

```bash
# ~/.dotfiles-extra/requirements.txt
pandas==2.0.0
scikit-learn>=1.3.0
torch

# ~/.dotfiles-extra/packages.txt
vim
tmux
htop
ripgrep

# ~/.dotfiles-extra/custom.sh
#!/bin/bash
echo "Running custom setup..."
# Your custom commands here
```

The install script automatically checks for and runs these files.

**Pros:**
- ✅ No forking needed
- ✅ Easy to maintain per-workspace customization
- ✅ Files can be gitignored or tracked separately

**Cons:**
- ❌ Need to create files before running dotfiles
- ❌ Less portable than env vars

---

### ✅ Pattern 3: Command Line Parameters
**Best for:** One-off customizations or testing

```bash
# Pass custom requirements file
./install.sh --pip-requirements ~/my-requirements.txt

# Pass custom packages
./install.sh --apt-packages "vim tmux htop"

# Run custom script after install
./install.sh --post-script ~/my-custom-setup.sh

# Combine multiple
./install.sh \
  --pip-requirements ~/requirements.txt \
  --apt-packages "vim tmux" \
  --post-script ~/setup.sh
```

**Pros:**
- ✅ No forking needed
- ✅ Explicit and clear what's being added
- ✅ Great for testing

**Cons:**
- ❌ Harder to automate with Coder
- ❌ Need to remember parameters

---

### ⚠️ Pattern 4: Fork + Override (Traditional)
**Best for:** Complete customization or when you need version control

1. Fork the base dotfiles repo
2. Modify `install.sh` directly
3. Point Coder to your fork

**Pros:**
- ✅ Full control
- ✅ Version controlled

**Cons:**
- ❌ Need to maintain fork
- ❌ Harder to pull upstream updates
- ❌ Duplicate repos for each user

---

## 🚀 Implementation Examples

### Example 1: Data Science Team

**Team Lead:** Sets up base dotfiles with common tools
**Data Scientists:** Add their own packages via env vars

```bash
# In Coder template (main.tf)
resource "coder_agent" "main" {
  env = {
    # Team-wide defaults
    DOTFILES_EXTRA_PIP = "pandas numpy matplotlib jupyter"
    
    # Users can override this in their workspace
  }
}
```

**Individual user** adds personal tools:
```bash
# In workspace ~/.bashrc or Coder env
export DOTFILES_EXTRA_PIP="$DOTFILES_EXTRA_PIP torch transformers"
```

---

### Example 2: Multi-Language Developer

```bash
# Environment variables approach
export DOTFILES_EXTRA_PIP="black flake8 pytest"
export DOTFILES_EXTRA_NPM="typescript @types/node eslint"
export DOTFILES_EXTRA_APT="build-essential golang-go"

coder dotfiles https://github.com/ly2xxx/coder-dotfiles-example
```

---

### Example 3: Custom Company Tools

```bash
# Override file approach
mkdir -p ~/.dotfiles-extra

# Python dependencies
cat > ~/.dotfiles-extra/requirements.txt <<EOF
company-internal-lib==1.2.3
aws-cli>=2.0.0
kubectl>=1.28.0
EOF

# System packages
cat > ~/.dotfiles-extra/packages.txt <<EOF
postgresql-client
redis-tools
jq
EOF

# Custom setup script
cat > ~/.dotfiles-extra/custom.sh <<'EOF'
#!/bin/bash
# Configure company VPN
wget https://company.com/vpn-config.sh
chmod +x vpn-config.sh
./vpn-config.sh
EOF

chmod +x ~/.dotfiles-extra/custom.sh

# Run dotfiles (it will pick up the override files)
coder dotfiles https://github.com/ly2xxx/coder-dotfiles-example
```

---

## 📝 Environment Variable Reference

| Variable | Description | Example |
|----------|-------------|---------|
| `DOTFILES_EXTRA_PIP` | Additional pip packages | `"pandas numpy torch"` |
| `DOTFILES_EXTRA_NPM` | Additional npm packages | `"typescript eslint"` |
| `DOTFILES_EXTRA_APT` | Additional apt packages | `"vim tmux htop"` |
| `DOTFILES_CUSTOM_REPO` | Clone custom git repo | `"https://github.com/user/scripts.git"` |
| `DOTFILES_CUSTOM_SCRIPT` | Run custom script URL | `"https://example.com/setup.sh"` |
| `DOTFILES_SKIP_DEFAULT` | Skip default installations | `"true"` |
| `DOTFILES_VERBOSE` | Enable debug output | `"true"` |

---

## 🔧 Local Override File Locations

The install script automatically checks for:

```
~/.dotfiles-extra/
  ├── requirements.txt     # Python pip packages
  ├── packages.txt         # System apt packages
  ├── npm-packages.txt     # Node.js packages
  ├── custom.sh            # Custom shell script (runs last)
  └── env.sh               # Environment variables to source
```

---

## 🎨 Best Practices

### ✅ Do:
1. **Use env vars for team defaults** - Set in Coder template
2. **Use override files for personal customization** - Keep in dotfiles repo or separate
3. **Document your extensions** - Add README to `.dotfiles-extra/`
4. **Version control your override files** - Separate repo or private gist
5. **Test locally first** - Run `./install.sh` before pushing to Coder

### ❌ Don't:
1. **Don't fork unless absolutely necessary** - Hard to maintain
2. **Don't hardcode secrets** - Use env vars or secret managers
3. **Don't install everything** - Only what you actually need
4. **Don't skip documentation** - Future you will thank you

---

## 🧪 Testing Your Extensions

### Local Test
```bash
# Set env vars
export DOTFILES_EXTRA_PIP="requests"
export DOTFILES_VERBOSE="true"

# Run install script
cd coder-dotfiles-example
./install.sh
```

### Coder Test
```bash
# Create workspace with env vars
coder create my-test-workspace \
  --parameter dotfiles_url="https://github.com/ly2xxx/coder-dotfiles-example" \
  --env DOTFILES_EXTRA_PIP="pandas numpy"
```

---

## 🔄 Migration Path

### From Fork to Extensible

**Before (forked):**
```bash
# Maintained your own fork
coder dotfiles https://github.com/yourusername/dotfiles-fork
```

**After (extensible):**
```bash
# Use base repo + env vars
export DOTFILES_EXTRA_PIP="your-custom-packages"
coder dotfiles https://github.com/ly2xxx/coder-dotfiles-example
```

**Benefits:**
- ✅ Receive base updates automatically
- ✅ No merge conflicts
- ✅ Easier to share with team

---

## 📚 Real-World Examples

### Example: ML Engineer
```bash
# In Coder workspace env
DOTFILES_EXTRA_PIP="torch torchvision transformers datasets accelerate"
DOTFILES_EXTRA_APT="nvidia-cuda-toolkit"
DOTFILES_CUSTOM_REPO="https://github.com/mycompany/ml-scripts.git"
```

### Example: DevOps Engineer
```bash
# Override files approach
cat > ~/.dotfiles-extra/requirements.txt <<EOF
ansible
terraform-cli
aws-cli
kubectl
helm
EOF

cat > ~/.dotfiles-extra/custom.sh <<'EOF'
#!/bin/bash
# Install k9s
curl -sS https://webinstall.dev/k9s | bash
EOF
```

### Example: Full-Stack Developer
```bash
export DOTFILES_EXTRA_PIP="django djangorestframework"
export DOTFILES_EXTRA_NPM="react @types/react next"
export DOTFILES_EXTRA_APT="postgresql redis"
```

---

## 🎯 Recommendation

**For most users:** Start with **Environment Variables** (Pattern 1)
- Set in Coder template for team defaults
- Override per workspace as needed
- No forking, easy updates

**For advanced users:** Combine **Env Vars + Override Files**
- Team defaults via env vars
- Personal customization via `.dotfiles-extra/`
- Best flexibility without forking

---

## 🚧 Coming Soon

Planned enhancements:
- [ ] YAML config file support (`~/.dotfiles.yaml`)
- [ ] Plugin system for modular extensions
- [ ] Pre/post hooks for custom logic
- [ ] Dependency resolution and conflict detection

---

## 📖 Related Resources

- [Coder Dotfiles Docs](https://coder.com/docs/user-guides/workspace-dotfiles)
- [Dotfiles Best Practices](https://dotfiles.github.io/)
- [12 Factor App Config](https://12factor.net/config)

---

**Questions?** Open an issue or submit a PR with your extension pattern!

#!/bin/bash
#
# Extensible Dotfiles Installation Script
# Supports multiple extension patterns for custom dependencies
#
# Usage:
#   ./install.sh [OPTIONS]
#
# Options:
#   --pip-requirements FILE   Install Python packages from FILE
#   --apt-packages "PKG..."   Install system packages
#   --npm-packages "PKG..."   Install Node.js packages
#   --post-script FILE        Run custom script after installation
#   --skip-defaults           Skip default installations
#   --verbose                 Enable debug output
#   --help                    Show this help message
#
# Environment Variables:
#   DOTFILES_EXTRA_PIP       Additional pip packages
#   DOTFILES_EXTRA_APT       Additional apt packages
#   DOTFILES_EXTRA_NPM       Additional npm packages
#   DOTFILES_CUSTOM_REPO     Git repo to clone
#   DOTFILES_CUSTOM_SCRIPT   URL of script to download and run
#   DOTFILES_SKIP_DEFAULT    Skip default installations (true/false)
#   DOTFILES_VERBOSE         Enable verbose output (true/false)
#

set -e  # Exit on error

# ============================================
# Configuration & Defaults
# ============================================

# Parse command line arguments
PIP_REQUIREMENTS_FILE=""
APT_PACKAGES_EXTRA=""
NPM_PACKAGES_EXTRA=""
POST_SCRIPT=""
SKIP_DEFAULTS="${DOTFILES_SKIP_DEFAULT:-false}"
VERBOSE="${DOTFILES_VERBOSE:-false}"

while [[ $# -gt 0 ]]; do
    case $1 in
        --pip-requirements)
            PIP_REQUIREMENTS_FILE="$2"
            shift 2
            ;;
        --apt-packages)
            APT_PACKAGES_EXTRA="$2"
            shift 2
            ;;
        --npm-packages)
            NPM_PACKAGES_EXTRA="$2"
            shift 2
            ;;
        --post-script)
            POST_SCRIPT="$2"
            shift 2
            ;;
        --skip-defaults)
            SKIP_DEFAULTS="true"
            shift
            ;;
        --verbose)
            VERBOSE="true"
            shift
            ;;
        --help)
            head -n 20 "$0" | grep "^#" | sed 's/^# //'
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Run with --help for usage"
            exit 1
            ;;
    esac
done

# Get the directory where this script lives
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Override directory for custom configs
DOTFILES_EXTRA_DIR="${HOME}/.dotfiles-extra"

# ============================================
# Helper Functions
# ============================================

log() {
    echo "🔹 $*"
}

log_success() {
    echo "✅ $*"
}

log_warn() {
    echo "⚠️  $*"
}

log_error() {
    echo "❌ $*"
}

log_verbose() {
    if [ "$VERBOSE" = "true" ]; then
        echo "🔍 $*"
    fi
}

# Function to create symlink
link_file() {
    local src=$1
    local dest=$2
    
    if [ -e "$dest" ]; then
        log_warn "$dest already exists, backing up..."
        mv "$dest" "${dest}.backup-$(date +%Y%m%d-%H%M%S)"
    fi
    
    log "Linking $src -> $dest"
    ln -sf "$src" "$dest"
}

# Function to install pip packages
install_pip_packages() {
    local packages="$1"
    if [ -z "$packages" ]; then
        return
    fi
    
    log "Installing Python packages: $packages"
    for pkg in $packages; do
        log_verbose "Installing pip package: $pkg"
        pip3 install --user --upgrade --break-system-packages "$pkg" || log_warn "Failed to install $pkg"
    done
}

# Function to install apt packages
install_apt_packages() {
    local packages="$1"
    if [ -z "$packages" ]; then
        return
    fi
    
    log "Installing system packages: $packages"
    sudo apt-get update -qq
    for pkg in $packages; do
        log_verbose "Installing apt package: $pkg"
        sudo apt-get install -y -qq "$pkg" || log_warn "Failed to install $pkg"
    done
}

# Function to install npm packages
install_npm_packages() {
    local packages="$1"
    if [ -z "$packages" ]; then
        return
    fi
    
    log "Installing Node.js packages: $packages"
    for pkg in $packages; do
        log_verbose "Installing npm package: $pkg"
        npm install -g "$pkg" || log_warn "Failed to install $pkg"
    done
}

# ============================================
# Banner
# ============================================

echo "======================================"
echo "🎉 Extensible Dotfiles Setup 🎉"
echo "======================================"
echo "Timestamp: $(date)"
echo "User: $(whoami)"
echo "Hostname: $(hostname)"
echo "Dotfiles: $DOTFILES_DIR"
if [ "$SKIP_DEFAULTS" = "true" ]; then
    echo "Mode: Custom only (skipping defaults)"
else
    echo "Mode: Defaults + Custom extensions"
fi
echo "======================================"
echo ""

# ============================================
# Symlink Dotfiles
# ============================================

log "Setting up dotfiles..."
if [ -f "$DOTFILES_DIR/.bashrc" ]; then
    link_file "$DOTFILES_DIR/.bashrc" "$HOME/.bashrc"
fi
if [ -f "$DOTFILES_DIR/.gitconfig" ]; then
    link_file "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
fi
echo ""

# ============================================
# Install Default Dependencies
# ============================================

if [ "$SKIP_DEFAULTS" != "true" ]; then
    log "Installing default dependencies..."
    
    # Check Python
    if ! command -v python3 &> /dev/null; then
        log "Installing Python3..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get update
            sudo apt-get install -y python3 python3-pip
        fi
    fi
    
    # Add Python user bin to PATH
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
    fi
    
    # Install default Python packages
    log "Installing Gemini CLI..."
    install_pip_packages "google-generativeai"
    
    log "Installing Playwright..."
    install_pip_packages "playwright"
    python3 -m playwright install chromium --with-deps &> /dev/null || log_warn "Playwright browser install had warnings"
    
    # Install xvfb
    if command -v apt-get &> /dev/null; then
        install_apt_packages "xvfb"
    fi
    
    # Clone personal repo
    log "Cloning personal repository..."
    REPO_DIR="$HOME/ly2xxx"
    if [ -d "$REPO_DIR" ]; then
        log_warn "Repository exists, pulling latest..."
        cd "$REPO_DIR" && git pull
    else
        git clone https://github.com/ly2xxx/ly2xxx.git "$REPO_DIR"
    fi
    
    log_success "Default dependencies installed!"
    echo ""
else
    log "Skipping default installations (SKIP_DEFAULTS=true)"
    echo ""
fi

# ============================================
# Extension Pattern 1: Environment Variables
# ============================================

log "Checking for environment variable extensions..."

if [ -n "$DOTFILES_EXTRA_PIP" ]; then
    log "Found DOTFILES_EXTRA_PIP: $DOTFILES_EXTRA_PIP"
    install_pip_packages "$DOTFILES_EXTRA_PIP"
fi

if [ -n "$DOTFILES_EXTRA_APT" ]; then
    log "Found DOTFILES_EXTRA_APT: $DOTFILES_EXTRA_APT"
    install_apt_packages "$DOTFILES_EXTRA_APT"
fi

if [ -n "$DOTFILES_EXTRA_NPM" ]; then
    log "Found DOTFILES_EXTRA_NPM: $DOTFILES_EXTRA_NPM"
    install_npm_packages "$DOTFILES_EXTRA_NPM"
fi

if [ -n "$DOTFILES_CUSTOM_REPO" ]; then
    log "Found DOTFILES_CUSTOM_REPO: $DOTFILES_CUSTOM_REPO"
    CUSTOM_REPO_DIR="$HOME/$(basename "$DOTFILES_CUSTOM_REPO" .git)"
    if [ -d "$CUSTOM_REPO_DIR" ]; then
        log_warn "Custom repo exists, pulling latest..."
        cd "$CUSTOM_REPO_DIR" && git pull
    else
        git clone "$DOTFILES_CUSTOM_REPO" "$CUSTOM_REPO_DIR"
        log_success "Cloned custom repo to $CUSTOM_REPO_DIR"
    fi
fi

if [ -n "$DOTFILES_CUSTOM_SCRIPT" ]; then
    log "Found DOTFILES_CUSTOM_SCRIPT: $DOTFILES_CUSTOM_SCRIPT"
    TEMP_SCRIPT=$(mktemp)
    curl -fsSL "$DOTFILES_CUSTOM_SCRIPT" -o "$TEMP_SCRIPT"
    chmod +x "$TEMP_SCRIPT"
    log "Running custom script..."
    bash "$TEMP_SCRIPT"
    rm "$TEMP_SCRIPT"
    log_success "Custom script executed!"
fi

echo ""

# ============================================
# Extension Pattern 2: Local Override Files
# ============================================

log "Checking for local override files in $DOTFILES_EXTRA_DIR..."

if [ -d "$DOTFILES_EXTRA_DIR" ]; then
    log "Found override directory!"
    
    # Python requirements
    if [ -f "$DOTFILES_EXTRA_DIR/requirements.txt" ]; then
        log "Installing Python packages from requirements.txt..."
        pip3 install --user --upgrade --break-system-packages -r "$DOTFILES_EXTRA_DIR/requirements.txt"
        log_success "Python requirements installed!"
    fi
    
    # System packages
    if [ -f "$DOTFILES_EXTRA_DIR/packages.txt" ]; then
        log "Installing system packages from packages.txt..."
        while IFS= read -r pkg; do
            [ -z "$pkg" ] && continue
            [[ "$pkg" =~ ^# ]] && continue  # Skip comments
            install_apt_packages "$pkg"
        done < "$DOTFILES_EXTRA_DIR/packages.txt"
        log_success "System packages installed!"
    fi
    
    # NPM packages
    if [ -f "$DOTFILES_EXTRA_DIR/npm-packages.txt" ]; then
        log "Installing npm packages from npm-packages.txt..."
        while IFS= read -r pkg; do
            [ -z "$pkg" ] && continue
            [[ "$pkg" =~ ^# ]] && continue
            install_npm_packages "$pkg"
        done < "$DOTFILES_EXTRA_DIR/npm-packages.txt"
        log_success "NPM packages installed!"
    fi
    
    # Environment variables to source
    if [ -f "$DOTFILES_EXTRA_DIR/env.sh" ]; then
        log "Sourcing environment variables..."
        source "$DOTFILES_EXTRA_DIR/env.sh"
        # Also add to .bashrc for persistence
        echo "source $DOTFILES_EXTRA_DIR/env.sh" >> "$HOME/.bashrc"
        log_success "Environment variables loaded!"
    fi
    
    # Custom script (runs last)
    if [ -f "$DOTFILES_EXTRA_DIR/custom.sh" ]; then
        log "Running custom setup script..."
        chmod +x "$DOTFILES_EXTRA_DIR/custom.sh"
        bash "$DOTFILES_EXTRA_DIR/custom.sh"
        log_success "Custom script executed!"
    fi
else
    log_verbose "No override directory found at $DOTFILES_EXTRA_DIR"
fi

echo ""

# ============================================
# Extension Pattern 3: Command Line Arguments
# ============================================

log "Checking for command line extensions..."

if [ -n "$PIP_REQUIREMENTS_FILE" ]; then
    if [ -f "$PIP_REQUIREMENTS_FILE" ]; then
        log "Installing from $PIP_REQUIREMENTS_FILE..."
        pip3 install --user --upgrade --break-system-packages -r "$PIP_REQUIREMENTS_FILE"
        log_success "Requirements installed!"
    else
        log_error "Requirements file not found: $PIP_REQUIREMENTS_FILE"
    fi
fi

if [ -n "$APT_PACKAGES_EXTRA" ]; then
    log "Installing extra apt packages: $APT_PACKAGES_EXTRA"
    install_apt_packages "$APT_PACKAGES_EXTRA"
fi

if [ -n "$NPM_PACKAGES_EXTRA" ]; then
    log "Installing extra npm packages: $NPM_PACKAGES_EXTRA"
    install_npm_packages "$NPM_PACKAGES_EXTRA"
fi

if [ -n "$POST_SCRIPT" ]; then
    if [ -f "$POST_SCRIPT" ]; then
        log "Running post-installation script: $POST_SCRIPT"
        chmod +x "$POST_SCRIPT"
        bash "$POST_SCRIPT"
        log_success "Post-script executed!"
    else
        log_error "Post-script not found: $POST_SCRIPT"
    fi
fi

echo ""

# ============================================
# Summary & Next Steps
# ============================================

echo "======================================"
echo "✨ Dotfiles Setup Complete! ✨"
echo "======================================"
echo ""
echo "📊 Summary:"
echo "  - Dotfiles symlinked ✓"
[ "$SKIP_DEFAULTS" != "true" ] && echo "  - Default dependencies installed ✓"
[ -n "$DOTFILES_EXTRA_PIP" ] && echo "  - Extra pip packages: $DOTFILES_EXTRA_PIP ✓"
[ -n "$DOTFILES_EXTRA_APT" ] && echo "  - Extra apt packages: $DOTFILES_EXTRA_APT ✓"
[ -d "$DOTFILES_EXTRA_DIR" ] && echo "  - Override files processed ✓"
echo ""
echo "🚀 Next Steps:"
echo "  1. Restart your shell: source ~/.bashrc"
echo "  2. Test installations:"
echo "     - python3 -c 'import google.generativeai; print(\"Gemini OK\")'"
echo "     - python3 -c 'from playwright.sync_api import sync_playwright; print(\"Playwright OK\")'"
echo ""
echo "📖 Documentation:"
echo "  - Extension guide: cat $DOTFILES_DIR/EXTENSIBILITY-GUIDE.md"
echo "  - Override directory: $DOTFILES_EXTRA_DIR"
echo ""
echo "💡 Pro Tip: Use environment variables for easy customization!"
echo "   export DOTFILES_EXTRA_PIP=\"your-packages\""
echo ""

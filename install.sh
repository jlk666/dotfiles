#!/usr/bin/env bash
# Apply dotfiles from this repo to your home directory.
# macOS: full setup (Oh My Zsh, Ghostty, Starship, lazygit, yazi, tlrc).
# Linux/BSD: zsh first, then Oh My Zsh, Starship, lazygit, yazi, tlrc (no Ghostty symlink).
# Optional: linux/install.env (see comments in that file).
# Run from the repo root: ./install.sh

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS="$(uname -s)"
BACKUP="${DOTFILES_BACKUP_DIR:-$HOME/.dotfiles-backup-$(date +%Y%m%d%H%M%S)}"

if [ "$OS" != "Darwin" ] && [ -f "$ROOT/linux/install.env" ]; then
  set -a
  # shellcheck disable=SC1091
  . "$ROOT/linux/install.env"
  set +a
fi

backup_if_exists() {
  local f="$1"
  if [ -e "$f" ] && [ ! -L "$f" ]; then
    mkdir -p "$BACKUP"
    echo "Backing up: $f -> $BACKUP/"
    mv "$f" "$BACKUP/"
  fi
}

run_pkg() {
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
  else
    sudo "$@"
  fi
}

install_zsh_linux() {
  if command -v zsh >/dev/null 2>&1; then
    echo "    zsh already on PATH ($(command -v zsh))"
    return 0
  fi
  if [ "${DOTFILES_NO_SUDO:-0}" = "1" ]; then
    echo "zsh is not installed and DOTFILES_NO_SUDO=1. Install zsh, then re-run." >&2
    exit 1
  fi
  echo "    installing zsh via system package manager..."
  if command -v apt-get >/dev/null 2>&1; then
    run_pkg apt-get update -qq
    run_pkg apt-get install -y zsh
  elif command -v dnf >/dev/null 2>&1; then
    run_pkg dnf install -y zsh
  elif command -v yum >/dev/null 2>&1; then
    run_pkg yum install -y zsh
  elif command -v pacman >/dev/null 2>&1; then
    run_pkg pacman -S --noconfirm zsh
  elif command -v zypper >/dev/null 2>&1; then
    run_pkg zypper install -y zsh
  elif command -v apk >/dev/null 2>&1; then
    run_pkg apk add zsh
  elif command -v pkg >/dev/null 2>&1; then
    run_pkg pkg install -y zsh
  elif command -v brew >/dev/null 2>&1; then
    brew install zsh
  else
    echo "Could not install zsh automatically. Install zsh with your package manager, then re-run." >&2
    exit 1
  fi
}

if [ "$OS" != "Darwin" ]; then
  echo "==> zsh (Linux/BSD)"
  install_zsh_linux
fi

echo "==> Oh My Zsh (skip if already installed)"
if [ "${DOTFILES_SKIP_OH_MY_ZSH:-0}" = "1" ]; then
  echo "    skipped (DOTFILES_SKIP_OH_MY_ZSH=1)"
elif [ ! -d "$HOME/.oh-my-zsh" ]; then
  export RUNZSH=no
  export CHSH=no
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || {
    echo "Install Oh My Zsh failed; install manually from https://ohmyz.sh" >&2
    exit 1
  }
else
  echo "    ~/.oh-my-zsh already present"
fi

echo "==> Link .zshrc"
backup_if_exists "$HOME/.zshrc"
if [ "$OS" = "Darwin" ]; then
  ln -sf "$ROOT/zsh/.zshrc" "$HOME/.zshrc"
else
  ln -sf "$ROOT/zsh/.zshrc.linux" "$HOME/.zshrc"
fi

echo "==> Ghostty"
if [ "$OS" = "Darwin" ]; then
  GHOSTTY_SRC="$ROOT/ghostty/config.ghostty"
  GHOSTTY_DIR="$HOME/Library/Application Support/com.mitchellh.ghostty"
  GHOSTTY_DEST="$GHOSTTY_DIR/config.ghostty"
  mkdir -p "$GHOSTTY_DIR"
  if [ -e "$GHOSTTY_DEST" ] && [ ! -L "$GHOSTTY_DEST" ]; then
    backup_if_exists "$GHOSTTY_DEST"
  fi
  ln -sf "$GHOSTTY_SRC" "$GHOSTTY_DEST"
else
  echo "    skipped on non-macOS"
fi

echo "==> tlrc (tldr client)"
if [ "$OS" = "Darwin" ]; then
  TLRC_DIR="$HOME/Library/Application Support/tlrc"
  TLRC_SRC="$ROOT/tlrc/config.toml"
else
  TLRC_DIR="$HOME/.config/tlrc"
  TLRC_SRC="$ROOT/tlrc/config.linux.toml"
fi
mkdir -p "$TLRC_DIR"
if [ -e "$TLRC_DIR/config.toml" ] && [ ! -L "$TLRC_DIR/config.toml" ]; then
  backup_if_exists "$TLRC_DIR/config.toml"
fi
ln -sf "$TLRC_SRC" "$TLRC_DIR/config.toml"

echo "==> Starship, lazygit, yazi under ~/.config"
mkdir -p "$HOME/.config/lazygit" "$HOME/.config/yazi"
backup_if_exists "$HOME/.config/starship.toml"
ln -sf "$ROOT/starship.toml" "$HOME/.config/starship.toml"
backup_if_exists "$HOME/.config/lazygit/config.yml"
ln -sf "$ROOT/lazygit/config.yml" "$HOME/.config/lazygit/config.yml"
backup_if_exists "$HOME/.config/yazi/yazi.toml"
ln -sf "$ROOT/yazi/yazi.toml" "$HOME/.config/yazi/yazi.toml"

echo
echo "Done. Backup of replaced files: $BACKUP (if any)"
echo
if [ "$OS" = "Darwin" ]; then
  echo "Next on a new Mac (after Xcode CLT for git/curl, or use full Xcode):"
  echo "  1) Install Homebrew: https://brew.sh"
  echo "  2) brew install --cask font-meslo-lg-nerd-font"
  echo "  3) brew install ghostty lazygit yazi starship tlrc"
  echo "  4) In Ghostty, pick MesloLGM Nerd Font Mono to match the theme."
  echo "  5) Optional: to use the prompt in starship.toml, add to the end of .zshrc:"
  echo "       eval \"\$(starship init zsh)\""
  echo "     (and place it after Oh My Zsh if you use both, or use only starship and disable omz theme.)"
else
  echo "On Linux/BSD, zsh was installed or verified first; ~/.zshrc -> zsh/.zshrc.linux."
  echo "  Install tlrc, starship, lazygit, yazi from your distro or upstream."
  echo "  Install a Nerd Font if your terminal theme expects Meslo."
  echo "  Optional: chsh -s \"\$(command -v zsh)\" to make zsh your login shell."
  echo "  Optional: add to the end of .zshrc: eval \"\$(starship init zsh)\""
fi
echo

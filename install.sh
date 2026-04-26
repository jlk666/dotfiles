#!/usr/bin/env bash
# Apply dotfiles from this repo to your home directory.
# macOS: full setup (Oh My Zsh, Ghostty, Starship, lazygit, yazi, tlrc).
# Linux/BSD: Starship, lazygit, yazi, tlrc (Oh My Zsh optional; no Ghostty symlink).
# Run from the repo root: ./install.sh

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS="$(uname -s)"
BACKUP="${DOTFILES_BACKUP_DIR:-$HOME/.dotfiles-backup-$(date +%Y%m%d%H%M%S)}"

backup_if_exists() {
  local f="$1"
  if [ -e "$f" ] && [ ! -L "$f" ]; then
    mkdir -p "$BACKUP"
    echo "Backing up: $f -> $BACKUP/"
    mv "$f" "$BACKUP/"
  fi
}

echo "==> Oh My Zsh (skip if already installed)"
if [ "$OS" = "Darwin" ]; then
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    export RUNZSH=no
    export CHSH=no
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || {
      echo "Install Oh My Zsh failed; install manually from https://ohmyz.sh" >&2
      exit 1
    }
  else
    echo "    ~/.oh-my-zsh already present"
  fi
else
  echo "    skipped on non-macOS (install from https://ohmyz.sh if you use zsh)"
fi

echo "==> Link .zshrc"
backup_if_exists "$HOME/.zshrc"
ln -sf "$ROOT/zsh/.zshrc" "$HOME/.zshrc"

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
  echo "On Linux/BSD, install tlrc, starship, lazygit, yazi from your distro or upstream."
  echo "  Install a Nerd Font if your terminal theme expects Meslo."
fi
echo

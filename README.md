# dotfiles

Personal shell and terminal setup: **Oh My Zsh** (Agnoster, macOS installer in `install.sh`), **Ghostty**, **Starship** (optional in the shell), **lazygit**, **yazi**, and **tlrc**. On Linux/BSD, Ghostty uses `~/.config/ghostty/config` (or `$XDG_CONFIG_HOME/ghostty/config`); tlrc uses `tlrc/config.linux.toml` for the XDG cache path.

## What is in the repo

| Path in repo | Applied to |
|--------------|------------|
| `zsh/.zshrc` | `~/.zshrc` (symlink) |
| `ghostty/config.ghostty` | macOS: `~/Library/Application Support/com.mitchellh.ghostty/config.ghostty`; Linux/BSD: `~/.config/ghostty/config` (symlink) |
| `starship.toml` | `~/.config/starship.toml` (symlink) |
| `lazygit/config.yml` | `~/.config/lazygit/config.yml` (symlink) |
| `yazi/yazi.toml` | `~/.config/yazi/yazi.toml` (symlink) |
| `tlrc/config.toml` | macOS: `~/Library/Application Support/tlrc/config.toml` (symlink) |
| `tlrc/config.linux.toml` | Linux: `~/.config/tlrc/config.toml` (symlink) |

Oh My Zsh is **not** stored in git (too large, updates often). The install script uses the [official installer](https://github.com/ohmyzsh/ohmyzsh) and then points `~/.zshrc` at this repo.

## New Mac setup

1. Install [Homebrew](https://brew.sh), then:

   ```bash
   xcode-select --install   # if you need git / build tools
   brew install --cask font-meslo-lg-nerd-font
   brew install ghostty lazygit yazi starship tlrc
   ```

2. Install [MesloLGM Nerd](https://github.com/ryanoasis/nerd-fonts) if you want the font name to match the Ghostty config exactly: pick **MesloLGM Nerd Font Mono** in Ghostty, or use the cask above and pick the closest Meslo LGM Nerd family face.

3. Clone this repository and run the installer:

   ```bash
   git clone https://github.com/YOUR_USER/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   chmod +x install.sh
   ./install.sh
   ```

4. Open a new terminal. Adjust **JAVA_HOME**, Conda, and `edirect` paths in `zsh/.zshrc` if your new machine uses different install locations, then `git commit` the edits from this clone.

5. **Starship:** This repo only contains `starship.toml`. To use Starship as the prompt, add after the Oh My Zsh block in `.zshrc` (or switch theme — Starship and Agnoster together are usually redundant):

   ```zsh
   eval "$(starship init zsh)"
   ```

6. **Optional:** `~/.zprofile` is not in this repo. If you use OrbStack or similar, merge those snippets manually.

## Uploading to GitHub

On this machine, from `~/Documents/GitHub/dotfiles`:

```bash
git init
git add .
git commit -m "Initial dotfiles: zsh, Ghostty, starship, lazygit, yazi"
```

Create a new empty repository on GitHub (no README), then:

```bash
git remote add origin https://github.com/YOUR_USER/dotfiles.git
git branch -M main
git push -u origin main
```

Replace `YOUR_USER` with your GitHub username.

## Updating from your Mac

After editing live configs, sync back into the repo (if you use symlinks from `install.sh`, editing `~/dotfiles/...` is enough) and commit. If a file is still a plain copy, copy changes into the repo before committing.

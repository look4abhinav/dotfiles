# 🚀 Dotfiles

This repository contains my personal dotfiles and configuration files, managed using GNU `stow`. The setup is designed for a fast Wayland desktop. TUI applications use **Catppuccin Mocha**; the Hyprland shell uses a complementary cyan glass accent.

## 🛠️ Tools & Configurations Included

The following configurations are tracked in this repository:

- **Shell:** `zsh` with `zinit` for blazing-fast plugin management, and `powerlevel10k` for the prompt.
- **Terminal:** `ghostty` configured with Catppuccin and proper font settings.
- **Editor:** `neovim` (Lazy-based config).
- **Window Manager:** `hyprland` (Wayland compositor) with `hypridle`/`hyprlock` (idle & lock) and Waypaper/Hyprpaper for wallpapers.
- **Status Bar:** `quickshell` bar (QML, `~/.config/quickshell`) with frosted-glass blur through the `quickshell` layer namespace. Requires `quickshell` and `upower`.
- **Notifications & Menus:** `mako` (notifications), `fuzzel` (app launcher), and `wlogout` (logout menu).
- **Agent Workspaces:** `herdr` (terminal workspace manager for AI coding agents) with a tracked `config.toml`.
- **System Monitors:** `htop` (custom layout).
- **Package Manager:** `paru` (AUR helper) optimized for usability.
- **Utilities:** `bat`, `eza`, `zoxide`, `fzf`, `gh`, and `uv`.
- **Git:** Customized `~/.gitconfig` with identity, GitHub authentication, aliases, and workflow defaults; commit signing is user-managed.

## 🎨 Theme
The TUI stack uses **Catppuccin Mocha** across Neovim, Ghostty, and Bat. The Hyprland bar, Mako, and wlogout use a complementary "liquid glass" cyan accent on top of the Mocha base.

## 📥 Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/look4abhinav/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ```

2. **Deploy with GNU Stow:**
   Stow the repository into your home directory explicitly:
   ```bash
   stow --target="$HOME" --no-folding .
   ```
   The repository uses `.stow-local-ignore` to keep Git metadata, `AGENTS.md`, `README.md`, `.env`, caches, and editor artifacts out of `$HOME`.

3. **Configure voice dictation (optional):**
   ```bash
   cp .config/hypr/.env.example .config/hypr/.env
   chmod 600 .config/hypr/.env
   ```
   Fill in `OPENAI_API_KEY` and `OPENAI_BASE_URL`. The file is ignored by Git.

4. **Verify the desktop bar:**
   Quickshell and UPower must be installed and available on `PATH`. The bar is started by `~/.config/hypr/modules/autostart.lua` with `qs --no-duplicate`.

## 💡 Note on the `stow` Structure
This repository uses a "flat" stow layout that mirrors your home directory. The explicit `--target="$HOME"` form is required when the repository is not located directly under `$HOME`.

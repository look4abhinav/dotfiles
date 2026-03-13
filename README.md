# 🚀 Dotfiles

This repository contains my personal dotfiles and configuration files, managed using GNU `stow`. The setup is designed to be minimal, fast, and unified under the **Catppuccin Mocha** theme. 

## 🛠️ Tools & Configurations Included

The following configurations are tracked in this repository:

- **Shell:** `zsh` with `zinit` for blazing-fast plugin management, and `powerlevel10k` for the prompt.
- **Terminal:** `ghostty` configured with Catppuccin and proper font settings.
- **Editor:** `neovim` (Lazy-based config) and `zed` (configured with Ruff & Ty for Python).
- **Multiplexer:** `tmux` with `tpm` and `vim-tmux-navigator`.
- **System Monitors:** `htop` (custom layout).
- **Package Manager:** `paru` (AUR helper) optimized for usability.
- **Utilities:** `bat`, `eza`, `zoxide`, `fzf`, `gh`, and `uv`.
- **Git:** Customized `~/.gitconfig` with SSH commit signing.

## 🎨 Theme
The central theme across these dotfiles is **Catppuccin Mocha**, providing a consistent and beautiful experience across Neovim, Tmux, Ghostty, and Bat.

## 📥 Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/look4abhinav/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ```

2. **Deploy with GNU Stow:**
   Because of the flat structure used in this repository, you simply stow the current directory (`.`) into your home directory:
   ```bash
   stow .
   ```
   *Note: This will symlink `dotfiles/.config/*` into `~/.config/` and top-level files like `.zshrc` and `.gitconfig` directly to your home directory.*

## 💡 Note on the `stow` Structure
This repository uses a "flat" stow architecture, meaning the folder structure precisely mirrors your home directory layout. 
If you decide to split applications into their own individual stow packages (e.g., `~/dotfiles/nvim/.config/nvim`), you'll be able to install them piecemeal (e.g., `stow nvim`), but the current flat strategy works perfectly for "all-or-nothing" rapid deployment!

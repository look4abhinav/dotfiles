# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

if [[ -f "/opt/homebrew/bin/brew" ]] then
  # If you're using macOS, you'll want this enabled
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in Powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add in snippets
zinit snippet OMZL::git.zsh
zinit snippet OMZP::git
zinit snippet OMZP::gh
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux
zinit snippet OMZP::aws
zinit snippet OMZP::python
zinit snippet OMZP::command-not-found

# Load completions
autoload -Uz compinit && compinit
autoload zmv
zinit cdreplay -q

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region
bindkey ' ' magic-space
bindkey -s '^Ga' 'git add .'
bindkey -s '^Gc' 'git commit -m ""\C-b'

# Hook for cd
chpwd() {
    emulate -L zsh
    if [[ -n "$VIRTUAL_ENV" ]]; then
        local env_root="${VIRTUAL_ENV:h}"
        if [[ "$PWD" != "$env_root"* ]]; then
            deactivate
        fi
    fi

    local venv_name=".venv" 
    if [[ -d "$venv_name" ]]; then
        local absolute_venv_path="$PWD/$venv_name"
        if [[ "$VIRTUAL_ENV" == "$absolute_venv_path" ]]; then
            return
        fi
        
        source "$venv_name/bin/activate"
    fi
}

# History
HISTSIZE=50
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -alh $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -alh $realpath'

# Aliases
alias nv='nvim'
alias c='clear'
alias ls='eza -alh'
alias up='paru -Syu'
alias ca='clear; :> ~/.zsh_history'
alias path='print -l -- ${(s/:/)PATH}'
alias zrc='nv ~/.zshrc; source ~/.zshrc'
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}"'
alias upy='uv self update; uv tool install ruff@latest; uv tool install ty@latest'
alias pyc='find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null && find . -type d -name .ruff_cache -exec rm -rf {} + 2>/dev/null'

# Suffix Aliases
alias -s py='nvim'
alias -s env='bat'
alias -s yml='bat'
alias -s yaml='bat'
alias -s yaml='md'

# Shell integrations
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"

# UV Setup
. "$HOME/.local/bin/env"
eval "$(uv generate-shell-completion zsh)"


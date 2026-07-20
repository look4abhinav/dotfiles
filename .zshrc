# =============================================================================
# 1. P10K INSTANT PROMPT
# =============================================================================
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# =============================================================================
# 2. ZINIT PLUGIN MANAGER SETUP
# =============================================================================
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"
zinit ice depth=1; zinit light romkatv/powerlevel10k

# =============================================================================
# 3. PLUGINS & SNIPPETS
# =============================================================================
zinit wait lucid for \
    OMZL::git.zsh \
    OMZP::git \
    OMZP::gh \
    OMZP::sudo \
    OMZP::archlinux \
    OMZP::uv \
    OMZP::python \
    OMZP::command-not-found

zinit wait lucid for \
    zsh-users/zsh-completions \
    zsh-users/zsh-autosuggestions \
    Aloxaf/fzf-tab \
    atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
    zsh-users/zsh-syntax-highlighting

# =============================================================================
# 4. COMPLETIONS
# =============================================================================
autoload -Uz compinit
if [[ $(date +'%j') != $(stat -c '%j' ~/.zcompdump 2>/dev/null) ]]; then
  compinit
else
  compinit -C
fi

autoload zmv

# =============================================================================
# 5. THEME / PROMPT
# =============================================================================
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# =============================================================================
# 6. KEYBINDINGS
# =============================================================================
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region
bindkey ' ' magic-space
bindkey -s '^Ga' 'git add .'
bindkey -s '^Gc' 'git commit -m ""\C-b'

# =============================================================================
# 7. HOOKS & FUNCTIONS
# =============================================================================
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

# =============================================================================
# 8. HISTORY SETTINGS
# =============================================================================
HISTSIZE=10000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory sharehistory hist_ignore_space hist_ignore_all_dups hist_save_no_dups hist_ignore_dups hist_find_no_dups

# =============================================================================
# 9. COMPLETION STYLING
# =============================================================================
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -alh $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -alh $realpath'

# =============================================================================
# 10. ALIASES
# =============================================================================
alias nv='nvim'
alias c='clear'
alias ls='eza -alh'
alias up='paru -Syu'
alias upy='uv self update; uv tool upgrade --all'
alias path='print -l -- ${(s/:/)PATH}'
alias zrc='nv ~/.zshrc; source ~/.zshrc'
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias pyc='fd -H -I "^(__pycache__|\.ruff_cache|\.pytest_cache|\.mypy_cache|\.ipynb_checkpoints|\.eggs|\.tox)$|\.(egg-info|egg|pyc|pyo)$" -X rm -rf'

# =============================================================================
# 11. CACHED SHELL INTEGRATIONS (fzf, zoxide, uv)
# =============================================================================
EVAL_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh_evals"
mkdir -p "$EVAL_CACHE_DIR"

if [[ ! -f "$EVAL_CACHE_DIR/fzf.zsh" ]]; then fzf --zsh > "$EVAL_CACHE_DIR/fzf.zsh"; fi
source "$EVAL_CACHE_DIR/fzf.zsh"

if [[ ! -f "$EVAL_CACHE_DIR/zoxide.zsh" ]]; then zoxide init --cmd cd zsh > "$EVAL_CACHE_DIR/zoxide.zsh"; fi
source "$EVAL_CACHE_DIR/zoxide.zsh"

if [[ ! -f "$EVAL_CACHE_DIR/uv.zsh" ]]; then uv generate-shell-completion zsh > "$EVAL_CACHE_DIR/uv.zsh"; fi
source "$EVAL_CACHE_DIR/uv.zsh"

# =============================================================================
# 12. PATH & ENVIRONMENT VARIABLES
# =============================================================================
if [[ -d "$HOME/.opencode/bin" ]]; then
  export PATH="$PATH:$HOME/.opencode/bin"
fi

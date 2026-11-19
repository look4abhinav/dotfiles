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
    OMZP::gh \
    OMZP::sudo \
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
if [[ $(date +'%j') != $(date -r ~/.zcompdump +'%j' 2>/dev/null) ]]; then
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
bindkey -s '^Gp' 'git push origin'

# =============================================================================
# 7. HOOKS & FUNCTIONS
# =============================================================================
chpwd() {
    emulate -L zsh
    [[ ${AUTO_VENV:-0} == 1 ]] || return 0
    if [[ -n "$VIRTUAL_ENV" ]]; then
        local env_root="${VIRTUAL_ENV:h}"
        if [[ "$PWD" != "$env_root" && "$PWD" != "$env_root"/* ]]; then
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
command -v paru >/dev/null && alias up='paru -Syu' || alias up='sudo pacman -Syu'
alias upy='UV_NO_MODIFY_PATH=1 uv self update; uv tool upgrade --all'
alias showpath='print -l -- ${(s/:/)PATH}'
alias zrc='nv ~/.zshrc; source ~/.zshrc'
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias pyc='fd -H -I "^(__pycache__|\.ruff_cache|\.pytest_cache|\.mypy_cache|\.ipynb_checkpoints|\.eggs|\.tox)$|\.(egg-info|egg|pyc|pyo)$" -X rm -rf'

# =============================================================================
# 11. CACHED SHELL INTEGRATIONS (fzf, zoxide, uv, herdr)
# =============================================================================
if [[ -d "$HOME/.local/bin" && ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  export PATH="$HOME/.local/bin:$PATH"
fi

EVAL_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh_evals"
mkdir -p "$EVAL_CACHE_DIR"

cache_shell_integration() {
    local cache_file="$EVAL_CACHE_DIR/$1.zsh"
    local tmp_file
    shift

    if [[ ! -s "$cache_file" ]]; then
        command -v "$1" >/dev/null 2>&1 || return 0
        tmp_file="$(mktemp "${cache_file}.XXXXXX")" || return 0
        if "$@" > "$tmp_file" && [[ -s "$tmp_file" ]]; then
            mv -f "$tmp_file" "$cache_file"
        else
            rm -f "$tmp_file"
            return 0
        fi
    fi

    [[ -s "$cache_file" ]] && source "$cache_file"
}

cache_shell_integration fzf fzf --zsh
cache_shell_integration zoxide zoxide init --cmd cd zsh
cache_shell_integration uv uv generate-shell-completion zsh
cache_shell_integration herdr herdr completion zsh

unfunction cache_shell_integration

# =============================================================================
# 12. PATH & ENVIRONMENT VARIABLES
# =============================================================================
export EDITOR='nvim'

if [[ -f "$HOME/.local/bin/env" ]]; then
  . "$HOME/.local/bin/env"
fi

if [[ -d "$HOME/.opencode/bin" ]]; then
  case ":$PATH:" in
    *":$HOME/.opencode/bin:"*) ;;
    *) export PATH="$PATH:$HOME/.opencode/bin" ;;
  esac
fi


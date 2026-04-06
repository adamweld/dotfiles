## Options
setopt nocaseglob           # Case insensitive globbing
setopt rcexpandparam        # Array expansion with parameters
setopt nocheckjobs          # Don't warn about running processes when exiting
setopt numericglobsort      # Sort filenames numerically when it makes sense
setopt nobeep               # No beep
setopt autocd               # If only directory path is entered, cd there

## History
HISTFILE=~/.zhistory
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory        # Append history instead of overwriting
setopt inc_append_history   # Save commands immediately
setopt histignorealldups    # Deduplicate history
setopt histignorespace      # Don't save commands starting with space

## Completion
autoload -U compinit colors
compinit -d
colors

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'  # Case insensitive tab completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"     # Colored completion
zstyle ':completion:*' rehash true                          # Auto-find new executables in PATH
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

WORDCHARS=${WORDCHARS//\/[&.;]}  # Don't consider certain characters part of the word

## Keybindings
bindkey -e
bindkey '^[[1;5D' backward-word       # Ctrl+Left
bindkey '^[[1;5C' forward-word        # Ctrl+Right
bindkey '^H'      backward-kill-word  # Ctrl+Backspace

## Aliases
alias cp="cp -i"                      # Confirm before overwriting
alias df='df -h'                      # Human-readable sizes

## Colored man pages
export LESS_TERMCAP_mb=$'\E[01;32m'
export LESS_TERMCAP_md=$'\E[01;32m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;47;34m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;36m'
export LESS=-R

## LS colors (cross-platform)
if [[ "$(uname)" == "Darwin" ]]; then
    export CLICOLOR=1
else
    alias ls='ls --color=auto'
fi

## Plugins via zinit
ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME" ]]; then
    mkdir -p "$(dirname "$ZINIT_HOME")"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "$ZINIT_HOME/zinit.zsh"

zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-history-substring-search

# Bind up/down arrows to history substring search
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

## Prompt (Starship)
if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
fi

## Source shared aliases
if [[ -f "$HOME/.bash_aliases" ]]; then
    source "$HOME/.bash_aliases"
fi

## Source machine-local config (not tracked in dotfiles)
if [[ -f "$HOME/.zsh_local" ]]; then
    source "$HOME/.zsh_local"
fi

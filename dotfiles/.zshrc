eval "$(/Users/kingbri/.local/bin/mise activate zsh)" # added by https://mise.run/zsh

# Antidote
source $HOME/.antidote/antidote.zsh

# Completion
autoload -Uz compinit && compinit

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Aliases
alias ls='ls --color'

# Shell integrations
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"

# Starship
eval "$(starship init zsh)"

# Load antidote
antidote load

# Transient prompt config
TRANSIENT_PROMPT_TRANSIENT_PROMPT='$(starship module character)'

# Keybindings
bindkey '^f' autosuggest-accept

# Auto-start zellij
if [[ -o interactive ]] \
    && [[ -z "$ZELLIJ" ]] \
    && [[ -z "$NO_ZELLIJ" ]] \
    && command -v zellij >/dev/null 2>&1; then
    zellij
fi

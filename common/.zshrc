# ====================================== plugins ======================================

source "$HOME/.config/zsh/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
source "$HOME/.config/zsh/zsh-abbr/zsh-abbr.plugin.zsh"
source "$HOME/.config/zsh/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh"

# ====================================== options ======================================

typeset -U path cdpath fpath manpath

autoload -Uz compinit
compinit

# History options should be set in .zshrc and after oh-my-zsh sourcing.
HISTSIZE="10000"
SAVEHIST="10000"

HISTFILE="$HOME/.zsh_history"
mkdir -p "$(dirname "$HISTFILE")"

setopt HIST_FCNTL_LOCK
unsetopt APPEND_HISTORY
setopt HIST_IGNORE_DUPS
unsetopt HIST_IGNORE_ALL_DUPS
unsetopt HIST_SAVE_NO_DUPS
unsetopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_SPACE
unsetopt HIST_EXPIRE_DUPS_FIRST
setopt SHARE_HISTORY
unsetopt EXTENDED_HISTORY
unsetopt autocd

# fish-like line navigation binding
bindkey '^[[1;9D' beginning-of-line
bindkey '^[[1;9C' end-of-line
bindkey '^[[1;2D' beginning-of-line
bindkey '^[[1;2C' end-of-line

# environments
export EDITOR=nvim

# custom rc
source "$HOME/.shrc"

# ====================================== paths ======================================

# custom binary
export PATH=$PATH:$HOME/bin
export PATH=$PATH:$HOME/personal-scripts

# mason
export PATH=$PATH:$HOME/.local/share/nvim/mason/bin

# android
export JAVA_HOME='/Applications/Android Studio.app/Contents/jbr/Contents/Home'
export PATH=$PATH:$JAVA_HOME/bin
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/build-tools/35.0.0

# brew
export PATH=$PATH:/opt/homebrew/opt/postgresql@16/bin

# rust
export PATH=$PATH:$HOME/.cargo/bin

# claude
export PATH=$PATH:$HOME/.local/bin

# ====================================== 3rd party ======================================

# carapace
export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense' # optional
zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
source <(carapace _carapace)

# eza
alias -- eza='eza --git'
alias -- la='eza -a'
alias -- ll='eza -l'
alias -- lla='eza -la'
alias -- ls='eza'
alias -- lt='eza --tree'

# granted
function assume() {
  export GRANTED_ALIAS_CONFIGURED="true"
  source assume "$@"
  unset GRANTED_ALIAS_CONFIGURED
}

# mise
eval "$(mise activate zsh)"

# oh-my-posh
eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/config.json)"

# scmpuff
# export SCMPUFF_GIT_CMD='/usr/bin/git'
# eval "$(scmpuff init --shell=zsh --aliases=false)"

# tmux
function th() {
  local session_name
  session_name=$(basename "$PWD")

  if tmux has-session -t "$session_name" 2>/dev/null; then
    tmux attach-session -t "$session_name"
  else
    tmux new-session -s "$session_name"
  fi
}
function tks() {
  local sel
  local session_name
  sel=$(tmux list-sessions | fzf --prompt='Kill session> ') || return
  session_name=$(echo "$sel" | cut -d':' -f1)
  tmux kill-session -t "$session_name"
}

# yazi
function yy() {
  local tmp
  tmp="$(mktemp -t "yazi-cwd.XXXXX")"
  yazi "$@" --cwd-file="$tmp"
  local cwd
  if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd" || return
  fi
  rm -f -- "$tmp"
}

# zoxide
eval "$(zoxide init zsh)"

# fzf
if [[ -o zle ]]; then
  export FZF_DEFAULT_OPTS='--height ~10 --border double'
fi

# atuin
if [[ -o zle ]]; then
  eval "$(atuin init zsh --disable-up-arrow)"
fi

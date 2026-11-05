# ====================================== plugins ======================================

source "$HOME/.config/zsh/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
source "$HOME/.config/zsh/zsh-abbr/zsh-abbr.plugin.zsh"
source "$HOME/.config/zsh/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh"

# ====================================== options ======================================

typeset -U path cdpath fpath manpath

autoload -Uz compinit
compinit

# Native shell history complements Atuin's history database.
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

# don't require `brew trust` for my own third-party taps
export HOMEBREW_NO_REQUIRE_TAP_TRUST=1

# custom rc
[[ -f "$HOME/.shrc" ]] && source "$HOME/.shrc"

# ====================================== paths ======================================

# custom binary
export PATH=$PATH:$HOME/bin
export PATH=$PATH:$HOME/personal-scripts

# local bin
export PATH=$PATH:$HOME/.local/bin

# android
if [[ -d '/Applications/Android Studio.app/Contents/jbr/Contents/Home' ]]; then
  export JAVA_HOME='/Applications/Android Studio.app/Contents/jbr/Contents/Home'
  path+=("$JAVA_HOME/bin")
fi
if [[ -d "$HOME/Library/Android/sdk" ]]; then
  export ANDROID_HOME="$HOME/Library/Android/sdk"
  for android_dir in "$ANDROID_HOME/emulator" "$ANDROID_HOME/platform-tools" "$ANDROID_HOME/build-tools/35.0.0"; do
    [[ -d "$android_dir" ]] && path+=("$android_dir")
  done
  unset android_dir
fi

# brew
export PATH=$PATH:/opt/homebrew/opt/postgresql@16/bin

# rust
export PATH=$PATH:$HOME/.cargo/bin

# ====================================== 3rd party ======================================

# mise
eval "$(mise activate zsh)"

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

# Pure
fpath+=("$HOME/.config/zsh/pure")
autoload -Uz promptinit
promptinit
prompt pure
source "$HOME/.config/zsh/pure-style.zsh"
source "$HOME/.config/zsh/pure-compact.zsh"

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
  local tmp cwd result=0
  tmp="$(mktemp -t "yazi-cwd.XXXXX")" || return
  yazi "$@" --cwd-file="$tmp" || result=$?
  if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd" || result=$?
  fi
  rm -f -- "$tmp"
  return "$result"
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

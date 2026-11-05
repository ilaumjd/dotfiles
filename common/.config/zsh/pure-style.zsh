# Recreate the former Oh My Posh theme using Pure's asynchronous Git state.
zmodload zsh/datetime
typeset -gA prompt_pure_version_cache
typeset -g prompt_pure_right_text='' prompt_pure_right_plain=''
typeset -g prompt_pure_last_status=0

prompt_pure_theme_metadata() {
  local age output version tool executable icon color marker directory cache_key
  local -A detected

  age=$(command git log -1 --format=%cr 2>/dev/null) || age=''
  [[ -n "$age" ]] || strftime -s age '%H:%M:%S' "$EPOCHSECONDS"
  prompt_pure_right_plain=$age
  prompt_pure_right_text="%F{#a9b1d6}${age//\%/%%}%f"

  # Recognize projects from the current directory up to the home/root boundary.
  directory=$PWD
  while true; do
    for tool marker in go go.mod julia Project.toml lua .lua-version node package.json \
      node .node-version node .nvmrc php composer.json python pyproject.toml \
      python requirements.txt python .python-version ruby Gemfile ruby .ruby-version \
      rust Cargo.toml swift Package.swift; do
      [[ -f "$directory/$marker" ]] && detected[$tool]=1
    done
    [[ "$directory" == / || "$directory" == "$HOME" ]] && break
    directory=${directory:h}
  done
  [[ -n "$VIRTUAL_ENV" ]] && detected[python]=1

  for tool icon color in go '' '#7dcfff' julia '' '#bb9af7' lua '' '#7aa2f7' \
    node '' '#9ece6a' php '󰌟' '#7aa2f7' python '' '#e0af68' \
    ruby '' '#f7768e' rust '' '#ff9e64' swift '' '#ff9e64'; do
    executable=$tool
    [[ "$tool" == rust ]] && executable=rustc
    [[ -n ${detected[$tool]} && -n ${commands[$executable]} ]] || continue
    cache_key="$PWD|$PATH|$VIRTUAL_ENV|$tool"
    if (( ! ${+prompt_pure_version_cache[$cache_key]} )); then
      case "$tool" in
        go) output=$(command go version 2>/dev/null) ;;
        lua) output=$(command lua -v 2>&1) ;;
        rust) output=$(command rustc --version 2>/dev/null) ;;
        *) output=$(command "$tool" --version 2>/dev/null) ;;
      esac
      version=''
      if [[ "$output" =~ '([0-9]+\.[0-9]+(\.[0-9]+)?([a-zA-Z0-9.+-]*))' ]]; then
        version=$match[1]
      fi
      prompt_pure_version_cache[$cache_key]=$version
    fi
    version=${prompt_pure_version_cache[$cache_key]}
    [[ -n "$version" ]] || continue
    prompt_pure_right_plain+=" $icon $version"
    prompt_pure_right_text+=" %F{$color}$icon $version%f"
  done
}

prompt_pure_theme_layout() {
  local folder=${PWD:t} branch=${psvar[14]} branch_color='#7dcfff'
  local left_plain left_text padding gap
  [[ "$PWD" == "$HOME" ]] && folder='~'
  [[ "$PWD" == / ]] && folder=/
  left_plain="➜ $folder"
  left_text='%F{#7aa2f7}➜ %f%B%F{#bb9af7}%1~%f%b'
  if [[ -n "$branch" ]]; then
    if [[ -n "$prompt_pure_git_dirty" ]]; then
      branch_color='#f7768e'
    elif [[ "$prompt_pure_git_arrows" == *⇡* ]]; then
      branch_color='#7aa2f7'
      [[ "$prompt_pure_git_arrows" == *⇣* ]] && branch_color='#7dcfff'
    elif [[ "$prompt_pure_git_arrows" == *⇣* ]]; then
      branch_color='#b4f9f8'
    fi
    left_plain+=" ($branch)"
    left_text+=" %F{$branch_color}(%14v)%f"
  fi
  if (( prompt_pure_last_status )); then
    left_plain+=' ✘'
    left_text+=' %F{#f7768e}✘%f'
  fi

  gap=$(( COLUMNS - ${#left_plain} - ${#prompt_pure_right_plain} - 1 ))
  if (( gap > 1 )); then
    padding=${(l:$gap:: :)''}
    left_text+="$padding$prompt_pure_right_text"
  fi
  typeset -g prompt_pure_full_prompt="$left_text"$'\n''%F{#9ece6a}▶%f '
  PROMPT=$prompt_pure_full_prompt
  PROMPT2='%F{#7aa2f7}➜%f '
}

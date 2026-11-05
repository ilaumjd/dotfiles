# Keep Pure's two-line active prompt, without a leading blank line.

# Keep the customization outside the upstream submodule.
functions -c prompt_pure_preprompt_render prompt_pure_preprompt_render_original
prompt_pure_preprompt_render() {
  if [[ "${1:-}" == precmd ]]; then
    prompt_pure_preprompt_render_original "$@" > /dev/null
  else
    prompt_pure_preprompt_render_original "$@"
  fi
}

# Collapse the completed prompt while keeping the command in scrollback.
autoload -Uz add-zle-hook-widget
typeset -g prompt_pure_full_prompt=$PROMPT
prompt_pure_transient_line_finish() {
  PROMPT='%F{blue}❯%f '
  zle .reset-prompt
}
prompt_pure_transient_restore() {
  PROMPT=$prompt_pure_full_prompt
}
precmd_functions=(prompt_pure_transient_restore ${precmd_functions:#prompt_pure_transient_restore})
add-zle-hook-widget line-finish prompt_pure_transient_line_finish

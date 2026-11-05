# Keep Pure's two-line active prompt, without a leading blank line.

# Keep the customization outside the upstream submodule.
if (( ! $+functions[prompt_pure_preprompt_render_original] )); then
  functions -c prompt_pure_preprompt_render prompt_pure_preprompt_render_original
fi
prompt_pure_preprompt_render() {
  # Use precmd mode to update Pure's state without its own newline or redraw.
  prompt_pure_preprompt_render_original precmd > /dev/null
  if [[ "${1:-}" == precmd ]]; then
    prompt_pure_theme_metadata
  fi
  prompt_pure_theme_layout
  [[ "${1:-}" == precmd ]] || prompt_pure_reset_prompt
}

# Collapse the completed prompt while keeping the command in scrollback.
autoload -Uz add-zle-hook-widget
prompt_pure_transient_line_finish() {
  PROMPT='%F{#7aa2f7}➜%f  '
  zle .reset-prompt
}
prompt_pure_transient_restore() {
  typeset -g prompt_pure_last_status=$?
  PROMPT=$prompt_pure_full_prompt
}
precmd_functions=(prompt_pure_transient_restore ${precmd_functions:#prompt_pure_transient_restore})
add-zle-hook-widget line-finish prompt_pure_transient_line_finish

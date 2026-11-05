# Keep Pure on one line, with no blank line before each prompt.
prompt_newline=' '

# Keep the customization outside the upstream submodule.
functions -c prompt_pure_preprompt_render prompt_pure_preprompt_render_original
prompt_pure_preprompt_render() {
  if [[ "${1:-}" == precmd ]]; then
    prompt_pure_preprompt_render_original "$@" > /dev/null
  else
    prompt_pure_preprompt_render_original "$@"
  fi
}

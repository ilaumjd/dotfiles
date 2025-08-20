return {
  {
    "rose-pine/neovim",
    name = "rose-pine",
    opts = {
      variant = "main", -- auto, main, moon, or dawn
      dark_variant = "main", -- main, moon, or dawn
      dim_inactive_windows = false,
      extend_background_behind_borders = true,
      enable = {
        terminal = true,
        legacy_highlights = true, -- Improve compatibility for bad syntax combinations
        migrations = true, -- Handle deprecated options automatically
      },
      styles = {
        bold = true,
        italic = true,
        transparency = false,
      },
    },
  },

  {
    "saghen/blink.cmp",
    opts = {
      keymap = {
        ["<C-j>"] = { "select_next", "fallback" },
        ["<C-k>"] = { "select_prev", "fallback" },
      },
    },
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "rose-pine",
    },
  },
}

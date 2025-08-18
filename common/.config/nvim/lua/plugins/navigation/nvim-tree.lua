return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("nvim-tree").setup({
      sync_root_with_cwd = true,
      respect_buf_cwd = true,
      update_focused_file = {
        enable = true,
        update_root = true,
      },
      view = {
        adaptive_size = false,
        width = 30,
        side = "left",
        signcolumn = "no",
        preserve_window_proportions = false,
      },
      renderer = {
        group_empty = true,
        highlight_opened_files = "name",
        indent_markers = {
          enable = true,
        },
      },
      filters = {
        dotfiles = true,
      },
      actions = {
        open_file = {
          resize_window = true,
        },
      },
    })

    -- Auto-open nvim-tree when opening a directory
    local function open_nvim_tree(data)
      local directory = vim.fn.isdirectory(data.file) == 1

      if not directory then
        return
      end

      vim.cmd.cd(data.file)
      require("nvim-tree.api").tree.open()
    end

    vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_nvim_tree })

    -- Keymap to toggle tree and focus on current file
    vim.keymap.set("n", "<leader>e", function()
      vim.cmd("NvimTreeFindFileToggle")
    end, { desc = "Explorer" })
  end,
}

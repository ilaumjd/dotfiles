return {
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.5",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")

      telescope.setup({
        defaults = {
          mappings = {
            i = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
            },
            n = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
            },
          },
        },
      })

      local builtin = require("telescope.builtin")
      local function map(mode, l, r, opts)
        opts = opts or {}
        opts.buffer = bufnr
        vim.keymap.set(mode, l, r, opts)
      end

      -- Files
      map("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
      map("n", "<leader>fg", builtin.live_grep, { desc = "Find grep" })
      map("n", "<leader>fw", builtin.grep_string, { desc = "Find string" })
      map("n", "<leader>fr", function()
        builtin.oldfiles({ cwd_only = true })
      end, { desc = "Find recent files" })
      map("n", "<leader>fR", builtin.oldfiles, { desc = "Find recent files (global)" })

      -- Helpers
      map("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
      map("n", "<leader>fk", builtin.keymaps, { desc = "Keymaps" })
      map("n", "<leader>fh", builtin.help_tags, { desc = "Help" })
      map("n", "<leader>f:", builtin.command_history, { desc = "Command history" })
      map("n", "<leader>f;", builtin.commands, { desc = "Commands" })
      map("n", "<leader>fs", builtin.search_history, { desc = "Search history" })

      -- Git
      map("n", "<leader>gs", builtin.git_status, { desc = "Git status" })
      map("n", "<leader>gl", builtin.git_bcommits, { desc = "Git log" })
      map("n", "<leader>gc", builtin.git_commits, { desc = "Git commits" })

      -- Diagnostics
      map("n", "<leader>xX", builtin.diagnostics, { desc = "Diagnostics (all buffers)" })
      map("n", "<leader>xx", function()
        builtin.diagnostics({ bufnr = 0 })
      end, { desc = "Diagnostics" })
    end,
  },

  -- Telescope FZF extension
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
    config = function()
      require("telescope").setup({
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
        },
      })
      require("telescope").load_extension("fzf")
    end,
  },

  -- Telescope UI Select extension
  {
    "nvim-telescope/telescope-ui-select.nvim",
    config = function()
      require("telescope").setup({
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown({}),
          },
        },
      })
      require("telescope").load_extension("ui-select")
    end,
  },
}

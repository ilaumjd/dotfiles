---@diagnostic disable: lowercase-global
return {
  "akinsho/toggleterm.nvim",
  version = "*",
  config = function()
    local toggleterm = require("toggleterm")

    toggleterm.setup({
      open_mapping = [[<c-\>]],
      hide_numbers = true,
      shade_filetypes = {},
      shade_terminals = true,
      shading_factor = 2,
      start_in_insert = true,
      insert_mappings = true,
      persist_size = true,
      close_on_exit = true,
      shell = vim.o.shell,
      float_opts = {
        border = "curved",
        winblend = 0,
        highlights = {
          border = "Normal",
          background = "Normal",
        },
      },
    })

    local toggle_horizontal = function()
      toggleterm.toggle(111, nil, vim.fn.getcwd(), "horizontal")
    end
    local toggle_float = function()
      toggleterm.toggle(222, nil, vim.fn.getcwd(), "float")
    end

    vim.keymap.set("n", "<C-/>", toggle_horizontal, { desc = "Toggle horizontal terminal" })
    vim.keymap.set("n", "<C-?>", toggle_float, { desc = "Toggle floating terminal" })

    function _G.set_terminal_keymaps()
      local bufname = vim.api.nvim_buf_get_name(0)
      if not string.match(bufname, "toggleterm") or string.match(bufname, "lazygit") then
        return
      end

      local opts = { buffer = 0 }
      vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
      vim.keymap.set("t", "jk", [[<C-\><C-n>]], opts)

      vim.keymap.set({ "t", "n" }, "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
      vim.keymap.set({ "t", "n" }, "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
      vim.keymap.set({ "t", "n" }, "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
      vim.keymap.set({ "t", "n" }, "<C-l>", [[<Cmd>wincmd l<CR>]], opts)

      if string.match(bufname, "111") then
        vim.keymap.set({ "t", "n" }, "<C-/>", toggle_horizontal, opts)
        vim.keymap.set({ "t", "n" }, "<C-?>", toggle_horizontal, opts)
        vim.keymap.set("n", "q", toggle_horizontal, opts)
      elseif string.match(bufname, "222") then
        vim.keymap.set({ "t", "n" }, "<C-/>", toggle_float, opts)
        vim.keymap.set({ "t", "n" }, "<C-?>", toggle_float, opts)
        vim.keymap.set("n", "q", toggle_float, opts)
      end
    end

    vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")

    -- LazyGit
    local Terminal = require("toggleterm.terminal").Terminal
    local lazygit = Terminal:new({
      cmd = "lazygit",
      dir = "git_dir",
      direction = "float",
      float_opts = {
        border = "curved",
        winblend = 0,
        highlights = {
          border = "Normal",
          background = "Normal",
        },
      },
      on_open = function(term)
        vim.cmd("startinsert!")
        vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
      end,
      on_close = function()
        vim.cmd("startinsert!")
      end,
    })

    function _lazygit_toggle()
      lazygit:toggle()
    end

    vim.api.nvim_set_keymap(
      "n",
      "<leader>gg",
      "<cmd>lua _lazygit_toggle()<CR>",
      { desc = "LazyGit", noremap = true, silent = true }
    )
  end,
}

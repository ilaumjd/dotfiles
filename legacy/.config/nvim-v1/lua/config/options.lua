vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
local opt = vim.opt

opt.clipboard = "unnamedplus" -- Sync with system clipboard
opt.completeopt = "menu,menuone,noselect"
opt.expandtab = true -- Use spaces instead of tabs
opt.mouse = "a" -- Enable mouse mode
opt.number = true -- Print line number
opt.relativenumber = true -- Relative line numbers
opt.shiftwidth = 2 -- Size of an indent
opt.ignorecase = true -- Ignore case
opt.smartcase = true -- Don't ignore case with capitals
opt.smartindent = true -- Insert indents automatically
opt.splitbelow = true -- Put new windows below current
opt.splitright = true -- Put new windows right of current
opt.tabstop = 2 -- Number of spaces tabs count for
opt.termguicolors = true -- True color support
opt.timeoutlen = 300 -- For which-key plugin
opt.undofile = true
opt.cursorline = true
opt.linebreak = true
opt.scrolloff = 5
opt.sidescrolloff = 8

------ MACRO ------
local macro_enabled = false
vim.cmd("map q <Nop>")
vim.keymap.set("n", "<leader>cq", function()
  if macro_enabled then
    vim.cmd("map q <Nop>")
    macro_enabled = false
    vim.notify("Macro recording disabled")
  else
    vim.cmd("unmap q")
    macro_enabled = true
    vim.notify("Macro recording enabled")
  end
end, { desc = "Toggle macro" })

------ DIAGNOSTIC ------
vim.diagnostic.config({
  virtual_text = false,
})
vim.keymap.set("", "<leader>xv", function()
  local new_value = not vim.diagnostic.config().virtual_text
  vim.diagnostic.config({ virtual_text = new_value })
end, { desc = "Toggle virtual_text" })

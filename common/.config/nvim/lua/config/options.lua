-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

------ MACRO ------
vim.cmd("map q <Nop>")
local macro_enabled = false
vim.keymap.set("n", "<leader>cq", function()
  macro_enabled = not macro_enabled
  if macro_enabled then
    vim.cmd("unmap q")
    vim.notify("Macro recording enabled")
  else
    vim.cmd("map q <Nop>")
    vim.notify("Macro recording disabled")
  end
end, { desc = "Toggle macro" })

------ VIRTUAL TEXT ------
vim.diagnostic.config({
  virtual_text = false,
})
local virtual_text_enabled = false
vim.keymap.set("", "<leader>xv", function()
  virtual_text_enabled = not virtual_text_enabled
  vim.diagnostic.config({ virtual_text = virtual_text_enabled })
  if virtual_text_enabled then
    vim.notify("Virtual text enabled")
  else
    vim.notify("Virtual text disabled")
  end
end, { desc = "Toggle virtual_text" })

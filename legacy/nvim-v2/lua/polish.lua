-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

-- Disable macro on startup
vim.cmd "map q <Nop>"

-- Macro: @l
local esc = vim.api.nvim_replace_termcodes("<Esc>", true, true, true)
vim.api.nvim_create_augroup("JSLogMacro", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = "JSLogMacro",
  pattern = { "javascript", "typescript" },
  callback = function() vim.fn.setreg("l", 'yoconsole.log("' .. esc .. 'pa:", ' .. esc .. "pa);" .. esc) end,
})

-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

------ DISABLE HIGHLGHT AFTER SEARCH ------
-- vim.cmd([[
--   augroup disable_highlight_after_search
--     autocmd!
--     autocmd CursorMoved * set nohlsearch
--   augroup END
-- ]])

------ STARTER ------
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argc() == 0 and vim.fn.line2byte("$") == -1 then
      require("startup").display()
    end
  end,
})

------ LAZY VIM ------
local function augroup(name)
  return vim.api.nvim_create_augroup("lazyvim_" .. name, { clear = true })
end

-- Check if we need to reload the file when it changed
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup("checktime"),
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Resize splits if window got resized
vim.api.nvim_create_autocmd({ "VimResized" }, {
  group = augroup("resize_splits"),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

-- Go to last loc when opening a buffer
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("last_loc"),
  callback = function(event)
    local exclude = { "gitcommit" }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then
      return
    end
    vim.b[buf].lazyvim_last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Wrap and check for spell in text filetypes
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("wrap_spell"),
  pattern = { "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- Fix conceallevel for json files
vim.api.nvim_create_autocmd({ "FileType" }, {
  group = augroup("json_conceal"),
  pattern = { "json", "jsonc", "json5" },
  callback = function()
    vim.opt_local.conceallevel = 0
  end,
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  group = augroup("auto_create_dir"),
  callback = function(event)
    if event.match:match("^%w%w+://") then
      return
    end
    local file = vim.loop.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- Big file optimizations
vim.g.bigfile_size = 1024 * 1024 -- 1MB
vim.filetype.add({
  pattern = {
    [".*"] = {
      function(path, bufnr)
        local size = vim.fn.getfsize(path)
        return size > vim.g.bigfile_size and "bigfile" or nil
      end,
    },
  },
})

vim.api.nvim_create_autocmd({ "FileType" }, {
  group = augroup("bigfile"),
  pattern = "bigfile",
  callback = function(ev)
    vim.b.minianimate_disable = true
    vim.opt_local.syntax = vim.filetype.match({ buf = ev.buf }) or ""
  end,
})

-- Close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = {
    -- default
    "checkhealth",
    "help",
    "lspinfo",
    "man",
    "notify",
    "qf",

    -- plugin
    "TelescopePrompt",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>q!<cr>", { buffer = event.buf, silent = true })
  end,
})

-- Close buffers with specific name patterns with <q>
vim.api.nvim_create_autocmd({ "BufAdd", "BufCreate", "BufFilePost" }, {
  group = augroup("close_with_q_names"),
  callback = function(event)
    local patterns = {
      "^Curl output",
      "curl$",
    }

    local buf_name = vim.fn.bufname(event.buf)
    if buf_name then
      for _, pattern in ipairs(patterns) do
        if buf_name:match(pattern) then
          vim.bo[event.buf].buflisted = false
          vim.keymap.set("n", "q", "<cmd>q!<cr>", { buffer = event.buf, silent = true })
          break
        end
      end
    end
  end,
})

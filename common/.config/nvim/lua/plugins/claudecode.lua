return {
  "coder/claudecode.nvim",
  lazy = true,
  dependencies = { "folke/snacks.nvim" },
  config = true,
  keys = {
    { "<leader>c", nil, desc = "Claude Code / Curl" },
    { "<Leader>cc", "<cmd>ClaudeCode<cr>", desc = "Claude: Toggle" },
    { "<Leader>cf", "<cmd>ClaudeCodeFocus<cr>", desc = "Claude: Focus" },
    { "<Leader>cm", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Claude: Select model" },
    { "<Leader>cb", "<cmd>ClaudeCodeAdd %<cr>", desc = "Claude: Add current buffer" },
    { "<Leader>cs", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Claude: Add current selection" },
    {
      "<Leader>cs",
      "<cmd>ClaudeCodeTreeAdd<cr>",
      desc = "Claude: Add file",
      ft = { "NvimTree", "neo-tree", "oil", "minifiles" },
    },
    -- Diff management
    { "<Leader>ca", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Claude: Accept diff" },
    { "<Leader>cd", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Claude: Deny diff" },
  },
}

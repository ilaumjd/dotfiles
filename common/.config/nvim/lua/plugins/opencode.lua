return {
  "NickvanDyke/opencode.nvim",
  lazy = true,
  dependencies = {
    "folke/snacks.nvim",
  },
  keys = {
    -- Basic commands
    {
      "<leader>ot",
      function() require("opencode").toggle() end,
      desc = "Toggle opencode",
    },
    {
      "<leader>on",
      function() require("opencode").command "session_new" end,
      desc = "New opencode session",
    },

    -- Ask prompts
    {
      "<leader>oa",
      function() require("opencode").ask() end,
      desc = "Ask opencode",
      mode = { "n", "v" },
    },
    {
      "<leader>ob",
      function() require("opencode").ask "@buffer " end,
      desc = "Ask about @buffer",
    },
    {
      "<leader>od",
      function() require("opencode").ask "@diagnostics " end,
      desc = "Ask about @diagnostics",
    },
    {
      "<leader>os",
      function() require("opencode").ask "@selection " end,
      desc = "Ask about @selection",
      mode = "v",
    },

    -- Explain code
    {
      "<leader>oB",
      function() require("opencode").prompt "Explain @buffer" end,
      desc = "Explain @file",
    },
    {
      "<leader>oD",
      function() require("opencode").prompt "Explain @diagnostics" end,
      desc = "Explain @diagnostics",
    },
    {
      "<leader>oS",
      function() require("opencode").prompt "Explain @selection" end,
      desc = "Explain @selection",
      mode = "v",
    },
  },
}

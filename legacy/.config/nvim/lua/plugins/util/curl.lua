return {
  "oysandvik94/curl.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    local curl = require("curl")
    curl.setup({
      mappings = {
        execute_curl = "<CR>",
      },
    })

    local function map(keymap, action, desc)
      vim.keymap.set("n", keymap, action, { desc = desc })
    end

    map("<leader>uu", function()
      curl.open_curl_tab()
    end, "Open local curl tab")

    map("<leader>ug", function()
      curl.open_global_tab()
    end, "Open global curl tab")

    map("<leader>uc", function()
      curl.create_global_collection()
    end, "Create curl collection")

    map("<leader>uf", function()
      curl.pick_global_collection()
    end, "Open curl collection")
  end,
}

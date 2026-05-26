--[[
  Vibecoding-First Neovim Config
  Companion editor to pi. Lean, fast, mini.nvim + snacks.nvim.
]]

vim.loader.enable()

---Plugin URL helper
---@param repo string
---@return string
_G.gh = function(repo)
	return "https://github.com/" .. repo
end

-- ---------------------------------------------------------------------------
-- Build hooks for plugins that need post-install steps
-- ---------------------------------------------------------------------------
local function run_build(name, cmd, cwd)
	local result = vim.system(cmd, { cwd = cwd }):wait()
	if result.code ~= 0 then
		local stderr = result.stderr or ""
		local stdout = result.stdout or ""
		local output = stderr ~= "" and stderr or stdout
		if output == "" then
			output = "No output from build command."
		end
		vim.notify(("Build failed for %s:\n%s"):format(name, output), vim.log.levels.ERROR)
	end
end

vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(ev)
		local name = ev.data.spec.name
		local kind = ev.data.kind
		if kind ~= "install" and kind ~= "update" then
			return
		end
		if name == "LuaSnip" then
			if vim.fn.has("win32") ~= 1 and vim.fn.executable("make") == 1 then
				run_build(name, { "make", "install_jsregexp" }, ev.data.path)
			end
			return
		end
	end,
})

-- ---------------------------------------------------------------------------
-- Load modules in order: settings → plugins → keymaps → autocmds
-- ---------------------------------------------------------------------------
require("settings")
require("plugins")
require("keymaps")
require("autocmds")

-- vim: ts=2 sts=2 sw=2 et

-- lua/dirfinder.lua
local M = {}

function M.find_dirs(opts)
	opts = opts or {}
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	local cwd = opts.cwd or vim.fn.getcwd()

	pickers
		.new(opts, {
			prompt_title = "Find Directories",
			cwd = cwd,
			finder = finders.new_oneshot_job({
				"fd",
				"--type",
				"d",
				"--hidden",
				"--exclude",
				".git",
				"--exclude",
				"node_modules",
				"--exclude",
				".cache",
			}, { cwd = cwd }),
			sorter = conf.generic_sorter(opts),
			previewer = false,
			attach_mappings = function(prompt_bufnr, map)
				local function selected_dir()
					local entry = action_state.get_selected_entry()
					if not entry then
						return nil
					end
					return vim.fn.fnamemodify(cwd .. "/" .. entry[1], ":p")
				end

				-- <CR>: open in oil
				actions.select_default:replace(function()
					local dir = selected_dir()
					actions.close(prompt_bufnr)
					if dir then
						require("oil").open(dir)
					end
				end)

				-- <C-t>: open in oil AND cd into it (tab-local)
				map({ "i", "n" }, "<C-t>", function()
					local dir = selected_dir()
					actions.close(prompt_bufnr)
					if dir then
						vim.cmd.tcd(vim.fn.fnameescape(dir))
						require("oil").open(dir)
					end
				end)

				return true
			end,
		})
		:find()
end

return M

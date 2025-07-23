return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "echasnovski/mini.icons" },
    config = function()
        local auto = require "lualine.themes.iceberg_dark"
        local lualine_modes = { "insert", "normal", "visual", "command", "replace", "inactive", "terminal" }
        for _, field in ipairs(lualine_modes) do
            if auto[field] and auto[field].c then
                auto[field].c.bg = "NONE"
            end
        end
		require("lualine").setup({
			options = {
				icons_enabled = true,
				theme = auto,
				component_separators = "|",
				section_separators = " ",
			},

			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch", "diff", "diagnostics" },
				lualine_c = { "filename" },
				lualine_x = { "lsp_status", "filetype", "fileformat" },
				lualine_y = { "progress" },
				lualine_z = { "location" },
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = { "filename" },
				lualine_x = { "location" },
				lualine_y = {},
				lualine_z = {},
			},
		})
	end,
}

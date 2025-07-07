function ColorMyPencils(color)
	color = color or "catppuccin"
	vim.cmd.colorscheme(color)

	vim.api.nvim_set_hl(0, "Normal", { bg = "None" })
	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "None" })
end


return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		config = function()
			require('catppuccin').setup({
				flavour = "mocha",
				transparent_background = true,
				show_end_of_buffer = false,
			})

			ColorMyPencils()
		end
	},
}

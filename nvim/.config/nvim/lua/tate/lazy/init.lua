return {

	{
		"nvim-lua/plenary.nvim",
		name = "plenary",
	},

	"eandrju/cellular-automaton.nvim",

	{
		"supermaven-inc/supermaven-nvim",
		cmd = "SupermavenStart",
		config = function()
			require("supermaven-nvim").setup({
				keymaps = {
					accept_suggestion = "<S-Tab>", -- accept current suggestion
					accept_word = "<Tab>", -- accept until end of next word
					clear_suggestion = "<C-]>", -- clear suggestion
				},
				ignore_filetypes = { cpp = true }, -- or { "cpp", }
			})
		end,
	},
}

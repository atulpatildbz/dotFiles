require'hop'.setup()
local opts = { noremap = true, silent = true }
local keymap = vim.api.nvim_set_keymap

keymap("n", "s", ":HopChar2<cr>", opts)

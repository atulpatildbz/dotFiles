local opts = { noremap = true, silent = true }
local term_opts = { silent = true }

local keymap = vim.api.nvim_set_keymap

-- set space as leader
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Modes
--  normal_mode = "n"
--  insert_mode = "i"
--  visual_mode = "v"
--  visual_line_mode = "V"
--  visual_block_mode = "X"
--  term_mode = "t"
--  command_mode = "c"

---------------------------------------------------------------------------------------------
-- All modes --

keymap("", "<S-Insert>", "<C-R>+", opts)


---------------------------------------------------------------------------------------------
-- Normal mode --

keymap("n", "Y", "y$", opts)

-- Better window navigation
keymap("n", "<C-h>", "<C-w>h", opts)
-- keymap("n", "<C-j>", "<C-w>j", opts) -- commented for now as this is used by Lspsaga diagnostic_jump_next
-- keymap("n", "<C-k>", "<C-w>k", opts) -- commented for now as this is used by Lspsaga diagnostic_jump_prev
keymap("n", "<C-l>", "<C-w>l", opts)

-- resize
keymap("n", "<C-Left>", ":vertical resize -5<cr>", opts)
keymap("n", "<C-Right>", ":vertical resize +5<cr>", opts)
keymap("n", "<C-Down>", ":resize -2<cr>", opts)
keymap("n", "<C-Up>", ":resize +2<cr>", opts)

-- file operations
keymap("n", "<leader>w", ":w!<cr>", opts)
keymap("n", "<leader>q", ":q!<cr>", opts)

keymap("n", "<leader>n", ":noh<cr>", opts)

-- tab operations
keymap("n", "<C-n>", ":tabnew<cr>", opts)
keymap("n", "<C-T>", ":tab split<cr>", opts)
keymap("n", "<leader><Tab>", ":tabnext<cr>", opts)
keymap("n", "<S-Tab>", ":tabprevious<cr>", opts)

keymap("n", "<leader>v", ":e $MYVIMRC<cr>", opts)       -- open vimrc

-- Telescope keybindings
keymap("n", "<leader>p", ":lua require'telescope.builtin'.builtin{}<CR>", opts)
keymap("n", "<leader>m", ":lua require'telescope.builtin'.oldfiles{}<CR>", opts)                                -- most recentuly used files
keymap("n", "<leader>b", ":lua require'telescope.builtin'.buffers{}<CR>", opts)                                 -- find buffer
keymap("n", "<leader>/", ":lua require'telescope.builtin'.current_buffer_fuzzy_find({layout_strategy='vertical'})<CR>", opts) -- find in current buffer       
keymap("n", "<leader>'", ":lua require'telescope.builtin'.marks{}<CR>", opts)                                   -- find bookmarks   
keymap("n", "<C-p>", ":lua require'telescope.builtin'.git_files({layout_strategy='vertical'})<CR>", opts)       -- git files
keymap("n", "<leader>rg", ":lua require'telescope.builtin'.live_grep({layout_strategy='vertical'})<CR>", opts)  -- ripgrep like grep through dir 
keymap("n", "<leader>cs", ":lua require'telescope.builtin'.colorscheme{}<CR>", opts)                            -- colorscheme
keymap("n", "<leader>:", ":lua require'telescope.builtin'.command_history{}<CR>", opts)
keymap("n", "<leader>f", ":lua require'telescope.builtin'.grep_string({layout_strategy='vertical'})<CR>", opts)
-- search in open files
keymap("n", "<leader>gb", ":lua require('telescope.builtin').live_grep({grep_open_files=true, layout_strategy='vertical'})<CR>", opts)
keymap("n", "gr", ":lua require'telescope.builtin'.lsp_references({layout_strategy='vertical'})<CR>", opts)

keymap("n", "<C-b>", ":NvimTreeFindFile<CR>", opts)

-- LSP keybindings
--  These options can be optimized later to only load the lsp when needed

-- add keymap for following
keymap("n", "gd", ":lua vim.lsp.buf.definition()<CR>", opts)
keymap("n", "gD", ":lua vim.lsp.buf.declaration()<CR>", opts)
keymap("n", "gi", ":lua vim.lsp.buf.implementation()<CR>", opts)
keymap("n", "K", ":Lspsaga hover_doc<CR>", opts)
keymap("n", "gf", ":lua vim.lsp.buf.formatting()<CR>", opts)
keymap("n", "gn", ":lua vim.lsp.buf.rename()<CR>", opts)
keymap("n", "ga", ":Lspsaga code_action<CR>", opts)
keymap("n", "gs", ":Lspsaga signature_help<CR>", opts)
keymap("n", "<C-j>", ":Lspsaga diagnostic_jump_next<CR>", opts)
keymap("n", "<C-k>", ":Lspsaga diagnostic_jump_prev<CR>", opts)
keymap("n", "gh", ":Lspsaga show_line_diagnostics<CR>", opts)

-- Register
keymap("n", "<leader>d", "\"_d", opts)

-- Yank file 
keymap("n", "<leader>Y", ":let @+ = expand('%:p')<CR>", opts)       -- copy full path
keymap("n", "yn", ":let @+ = expand('%:t')<CR>", opts)              -- copy just filename
keymap("n", "yp", ":let @+ = expand('%:p')<CR>", opts)              -- copy relative path

-- replace text. 
vim.cmd([[
nnoremap <leader>rb :%s/\\/\//g<CR>     " replace back slash with forward slash
nnoremap <leader>rn :%s/\\n/\r/g<CR>    " replace new line with carriage return
nnoremap <leader>rt :%s/\\t/\t/g<CR>    " replace tab with tab
]])

-- run terminal commands
keymap("n", "<leader>rr", ":lua vimCustomRunner()<CR>", { noremap = true, silent = true })
-- jest
keymap("n", "<leader>tf", ":lua require'jester'.run_file({cmd = 'npm run test -- $file --coverage=False', path_to_jest = 'npm run test'})<CR>", opts)
keymap("n", "<leader>tn", ":lua require'jester'.run({cmd = 'npm run test -- $file -t $result --coverage=False', path_to_jest = 'npm run test' })<CR>", opts)

-- Misc
keymap("n", "<A-S-f>", ":Format<CR>", opts) -- on press of Alt+Shift+f, run :Format 

-----------------------------------------------------------------------------------------------------------------------
-- Insert mode --

keymap("i", "jk", "<Esc>", opts)
keymap("i", "<C-j>", "<C-n>", opts)
keymap("i", "<C-k>", "<C-p>", opts)
vim.api.nvim_set_keymap('i', '<cr>', 'compe#confirm("<cr>")', { expr = true })


-----------------------------------------------------------------------------------------------------------------------
-- Visual mode --

keymap("v", ">", ">gv", opts)       -- keep selection after indent right 
keymap("v", "<", "<gv", opts)       -- keep selection after indent left 
keymap("v", "p", "\"_dP", opts)       -- do not yank after paste


-----------------------------------------------------------------------------------------------------------------------
-- Terminal mode --
-- keymap("t", "<leader><Esc>", "<C-\\><C-n>", opts)
keymap('t', '<esc>', [[<C-\><C-n>]], opts)
keymap('t', 'jk', [[<C-\><C-n>]], opts)
keymap('t', '<C-h>', [[<C-\><C-n><C-W>h]], opts)
keymap('t', '<C-j>', [[<C-\><C-n><C-W>j]], opts)
keymap('t', '<C-k>', [[<C-\><C-n><C-W>k]], opts)
keymap('t', '<C-l>', [[<C-\><C-n><C-W>l]], opts)

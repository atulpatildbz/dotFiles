syntax on
set relativenumber
set nu
set hidden
set noerrorbells
set tabstop=4 softtabstop=4

set shiftwidth=4
set expandtab
set smartindent
set smartcase
set ignorecase
set noswapfile
set nobackup
set undodir=~/.nvim/undodir
set undofile
set incsearch
set signcolumn=yes
"set clipboard=unnamed
set cursorline
" set mouse=a

call plug#begin(stdpath('data') . 'vimplug')
    Plug 'nvim-lua/plenary.nvim'
    Plug 'nvim-lua/popup.nvim'
    Plug 'nvim-telescope/telescope.nvim'
    Plug 'neovim/nvim-lspconfig'
    Plug 'kabouzeid/nvim-lspinstall'
    Plug 'glepnir/lspsaga.nvim'
    " Install nvim-cmp
    Plug 'hrsh7th/nvim-cmp'

    " Install snippet engine (This example installs [hrsh7th/vim-vsnip](https://github.com/hrsh7th/vim-vsnip))
    Plug 'hrsh7th/vim-vsnip'

    " Install the buffer completion source
    Plug 'hrsh7th/cmp-buffer'

    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
    Plug 'nvim-treesitter/nvim-treesitter-textobjects'

    Plug 'glepnir/galaxyline.nvim', { 'branch': 'main' }
    Plug 'kyazdani42/nvim-web-devicons'  " needed for galaxyline icons

    Plug 'NLKNguyen/papercolor-theme'
    Plug 'nikvdp/neomux'

    Plug 'tpope/vim-ragtag'
    Plug 'tpope/vim-surround'
    Plug 'tpope/vim-unimpaired'

    Plug 'tpope/vim-eunuch'
    Plug 'tpope/vim-fugitive'

    Plug 'tomtom/tcomment_vim'
    Plug 'lewis6991/gitsigns.nvim'
    Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
    Plug 'junegunn/fzf.vim'
    Plug 'nvim-lua/completion-nvim'

    Plug 'tjdevries/colorbuddy.vim'
    " Plug 'tjdevries/gruvbuddy.nvim'

    " Plug 'rktjmp/lush.nvim'
    " Plug 'ellisonleao/gruvbox.nvim'
    Plug 'folke/lsp-colors.nvim'
    Plug 'morhetz/gruvbox'
call plug#end()

colorscheme PaperColor
" lua require('colorbuddy').colorscheme('gruvbuddy')
" set background=dark " or light if you want light mode

let g:gruvbox_contrast_dark = 'hard'
let g:gruvbox_invert_selection = '0'
colorscheme gruvbox
set background=dark

let mapleader = " "
imap jk <Esc>l
inoremap <C-j> <C-n>
inoremap <C-k> <C-p>
nnoremap <leader>w :w! <CR>
nnoremap <leader>q :q! <CR>
nnoremap <leader>n :noh<cr>
map! <S-Insert> <C-R>+
nnoremap <C-n> :tabnew <CR>
nnoremap <C-T> :tab split<Cr>
nnoremap <leader>v :e $MYVIMRC<cr>

" >> Telescope bindings
nnoremap <Leader>pp :lua require'telescope.builtin'.builtin{}<CR>

" most recentuly used files
nnoremap <Leader>m :lua require'telescope.builtin'.oldfiles{}<CR>

" find buffer
nnoremap <Leader>b :lua require'telescope.builtin'.buffers{}<CR>

" find in current buffer
nnoremap <Leader>/ :lua require'telescope.builtin'.current_buffer_fuzzy_find{}<CR>

" bookmarks
nnoremap <Leader>' :lua require'telescope.builtin'.marks{}<CR>

" git files
nnoremap <C-p> :lua require'telescope.builtin'.git_files{}<CR>

" all files
" nnoremap <Leader>bfs :lua require'telescope.builtin'.find_files{}<CR>

" ripgrep like grep through dir
nnoremap <Leader>rg :lua require'telescope.builtin'.live_grep{}<CR>

" pick color scheme
nnoremap <Leader>cs :lua require'telescope.builtin'.colorscheme{}<CR>

" using fzf for now. keep checking if telescope works in future
nnoremap <Leader>f :Rg <C-R><C-W><CR>

" >> Lsp key bindings
nnoremap <silent> gd    <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> <C-]> <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> gD    <cmd>lua vim.lsp.buf.declaration()<CR>
nnoremap <silent> gr    <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <silent> gi    <cmd>lua vim.lsp.buf.implementation()<CR>
nnoremap <silent> K     <cmd>Lspsaga hover_doc<CR>
"nnoremap <silent> <C-k> <cmd>lua vim.lsp.buf.signature_help()<CR>
"nnoremap <silent> <C-p> <cmd>Lspsaga diagnostic_jump_prev<CR>
"nnoremap <silent> <C-n> <cmd>Lspsaga diagnostic_jump_next<CR>
nnoremap <silent> gf    <cmd>lua vim.lsp.buf.formatting()<CR>
nnoremap <silent> gn    <cmd>lua vim.lsp.buf.rename()<CR>
nnoremap <silent> ga    <cmd>Lspsaga code_action<CR>
xnoremap <silent> ga    <cmd>Lspsaga range_code_action<CR>
nnoremap <silent> gs    <cmd>Lspsaga signature_help<CR>

nnoremap Y y$
" copy relative path
nnoremap yp :let @+ = expand("%")<CR>
" copy full path
nnoremap <leader>Y :let @+ = expand("%:p")<CR>
" copy just filename
nnoremap yn :let @+ = expand("%:t")<CR>

" Gitsigns mapping
nnoremap <leader>hp :Gitsigns preview_hunk<CR>
nnoremap <leader>hs :Gitsigns stage_hunk<CR>

autocmd FileType python nnoremap <buffer><silent><leader>l "lyiwoSyncLog.info("***AtulLog <C-R>l: %s", <C-R>l)<Esc>
autocmd FileType javascript nnoremap <buffer><silent><leader>l "lyiwoconsole.info(<C-R>l)<Esc>

vnoremap > >gv

tnoremap <leader><Esc> <C-\><C-n>

" Completing settings
" Use <Tab> and <S-Tab> to navigate through popup menu
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" Set completeopt to have a better completion experience
set completeopt=menuone,noinsert,noselect

" Avoid showing message extra message when using completion
set shortmess+=c

"""
lua <<EOF
require("lsp")
require("treesitter")
require("statusbar")
-- require("_completion")
require("_gitsigns")
EOF
"""

"luafile ~/.config/nvim/lua/lsp.lua

lua << EOF
-- require'lspconfig'.pyright.setup{}
-- require'lspconfig'.tsserver.setup{}
-- require'lspconfig'.pylsp.setup{}
local nvim_lsp = require('lspconfig')
local on_attach = require('completion').on_attach
local servers = {
    'tsserver',
    'pylsp',
    }
for _, lsp in ipairs(servers) do
    nvim_lsp[lsp].setup {
        on_attach = on_attach,
        flags = {
            debounce_text_changes = 150,
        }
    }
end
EOF

lua << EOF
require("lsp-colors").setup({
  Error = "#db4b4b",
  Warning = "#e0af68",
  Information = "#0db9d7",
  Hint = "#10B981"
})
EOF

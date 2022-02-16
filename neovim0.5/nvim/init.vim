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
set clipboard=unnamed
set cursorline
set mouse=a

let g:netrw_bufsettings = 'relativenumber nu'

call plug#begin(stdpath('data') . 'vimplug')
    Plug 'nvim-lua/plenary.nvim'
    Plug 'nvim-lua/popup.nvim'
    Plug 'nvim-telescope/telescope.nvim'
    Plug 'neovim/nvim-lspconfig'
    " Plug 'kabouzeid/nvim-lspinstall'
    Plug 'williamboman/nvim-lsp-installer'
    Plug 'glepnir/lspsaga.nvim'
    " Install nvim-cmp
    Plug 'hrsh7th/nvim-cmp'

    " Install snippet engine (This example installs [hrsh7th/vim-vsnip](https://github.com/hrsh7th/vim-vsnip))
    Plug 'hrsh7th/vim-vsnip'
    Plug 'hrsh7th/vim-vsnip-integ'

    " Install the buffer completion source
    Plug 'hrsh7th/cmp-buffer'

    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
    Plug 'nvim-treesitter/nvim-treesitter-textobjects'

    Plug 'glepnir/galaxyline.nvim', { 'branch': 'main' }
    Plug 'kyazdani42/nvim-web-devicons'  " needed for galaxyline icons
    Plug 'kyazdani42/nvim-tree.lua'

    Plug 'NLKNguyen/papercolor-theme'
    Plug 'nikvdp/neomux'

    Plug 'tpope/vim-ragtag'
    Plug 'tpope/vim-surround'
    Plug 'tpope/vim-unimpaired'

    Plug 'tpope/vim-eunuch'
    Plug 'tpope/vim-fugitive'

    Plug 'b3nj5m1n/kommentary'
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
    Plug 'mhartington/formatter.nvim'
    Plug 'jiangmiao/auto-pairs'
    Plug 'nvim-treesitter/playground'
    Plug 'github/copilot.vim'
    " Plug 'Yggdroot/indentLine'
    Plug 'David-Kunz/jester'
    Plug 'folke/tokyonight.nvim', { 'branch': 'main' }
    Plug 'maxmellon/vim-jsx-pretty'
    Plug 'justinmk/vim-sneak'
    Plug 'kyazdani42/nvim-web-devicons' " for file icons
    Plug 'nono/vim-handlebars'
call plug#end()

" colorscheme PaperColor
" lua require('colorbuddy').colorscheme('gruvbuddy')
" set background=dark " or light if you want light mode

let g:gruvbox_contrast_dark = 'hard'
let g:gruvbox_invert_selection = '0'
colorscheme gruvbox
set background=dark

let mapleader = " "
imap jk <Esc>
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
nnoremap <Leader>f :lua require'telescope.builtin'.grep_string{}<CR>
nnoremap gr :lua require'telescope.builtin'.lsp_references{}<CR>

" >> Lsp key bindings
nnoremap <silent> gd    <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> <C-]> <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> gD    <cmd>lua vim.lsp.buf.declaration()<CR>
" nnoremap <silent> gr    <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <silent> gi    <cmd>lua vim.lsp.buf.implementation()<CR>
nnoremap <silent> K     :Lspsaga hover_doc<CR>
"nnoremap <silent> <C-k> <cmd>lua vim.lsp.buf.signature_help()<CR>
nnoremap <silent> <C-k> <cmd>Lspsaga diagnostic_jump_prev<CR>
nnoremap <silent> <C-j> <cmd>Lspsaga diagnostic_jump_next<CR>
nnoremap <silent> gf    <cmd>lua vim.lsp.buf.formatting()<CR>
nnoremap <silent> gn    <cmd>lua vim.lsp.buf.rename()<CR>
nnoremap <silent> ga    <cmd>Lspsaga code_action<CR>
xnoremap <silent> ga    <cmd>Lspsaga range_code_action<CR>
nnoremap <silent> gs    <cmd>Lspsaga signature_help<CR>
nnoremap <silent> <leader><Tab> gt
nnoremap <silent> <S-Tab> gT
nnoremap <silent> gh   <cmd>Lspsaga show_line_diagnostics<CR>

" on press of Alt+Shift+f, run :Format
nnoremap <silent> <A-S-f> :Format<CR>

nnoremap Y y$
nnoremap <leader>d "_d
" copy relative path
nnoremap yp :let @+ = expand("%")<CR>
" copy full path
nnoremap <leader>Y :let @+ = expand("%:p")<CR>
" copy just filename
nnoremap yn :let @+ = expand("%:t")<CR>

" replace mappings:
" execute the command :%s/\\/\//g on leader rb
nnoremap <leader>rb :%s/\\/\//g<CR>
" replace \\n with newline on leader rn
nnoremap <leader>rn :%s/\\n/\r/g<CR>
" replace \\t with tab on leader rt
nnoremap <leader>rt :%s/\\t/\t/g<CR>

nnoremap <leader>tf :lua require"jester".run_file({path_to_jest = 'npm run test', dap = {runtimeArgs = {'--no-coverage'}}})<CR>
nnoremap <leader>tn :lua require"jester".run({path_to_jest = 'npm run test', dap = {runtimeArgs = {'--no-coverage'}}})<CR>

" nnoremap <c-b> :Vex 30<cr>

" Gitsigns mapping
" nnoremap <leader>hp :Gitsigns preview_hunk<CR>
" nnoremap <leader>hs :Gitsigns stage_hunk<CR>

autocmd FileType python
            \ nnoremap <buffer><silent><leader>l "lyiwoSyncLog.info("***AtulLog <C-R>l: %s", <C-R>l)<Esc> |
            \ vnoremap <buffer><silent><leader>l "lyoSyncLog.info("***AtulLog <C-R>l: %s", <C-R>l)<Esc> 
autocmd FileType javascript
            \ nnoremap <buffer><silent><leader>l "lyiwoconsole.info(<C-R>l);<Esc> |
            \ vnoremap <buffer><silent><leader>l "lyoconsole.info(<C-R>l);<Esc>

vnoremap > >gv
vnoremap < <gv
vnoremap <leader>p "_dP

tnoremap <leader><Esc> <C-\><C-n>

" Completing settings
" Use <Tab> and <S-Tab> to navigate through popup menu
" inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
" inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" Set completeopt to have a better completion experience
set completeopt=menuone,noinsert,noselect

" Avoid showing message extra message when using completion
set shortmess+=c

" Snippets mapping
" Expand or jump
imap <expr> <C-l>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'
imap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : pumvisible() ? "\<C-n>" : '<Tab>'
imap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : pumvisible() ? "\<C-p>" : '<S-Tab>'

" overwriting these values by adding extra <Leader> so that it doesn't get in
" the way of showing buffer keymapping
let g:neomux_yank_buffer_map = "<Leader><Leader>by"
let g:neomux_paste_buffer_map = "<Leader><Leader>bp"


lua << EOF
require("lsp")
require("treesitter")
require("statusbar")
require("_gitsigns")
-- require("_completion")
EOF

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


require('formatter').setup({
  filetype = {
    javascript = {
      -- prettier
      function()
        return {
          exe = "prettier",
          args = {"--stdin-filepath", vim.fn.fnameescape(vim.api.nvim_buf_get_name(0))},
          stdin = true
        }
      end
    },
  }
})
EOF

lua << EOF
require("lsp-colors").setup({
  Error = "#db4b4b",
  Warning = "#e0af68",
  Information = "#0db9d7",
  Hint = "#10B981"
})
EOF


" tree
let g:nvim_tree_indent_markers = 1 "0 by default, this option shows indent markers when folders are open
let g:nvim_tree_git_hl = 1 "0 by default, will enable file highlight for git attributes (can be used without the icons).
let g:nvim_tree_highlight_opened_files = 1 "0 by default, will enable folder and file icon highlight for opened files/directories.
let g:nvim_tree_root_folder_modifier = ':~' "This is the default. See :help filename-modifiers for more options
let g:nvim_tree_add_trailing = 1 "0 by default, append a trailing slash to folder names
let g:nvim_tree_group_empty = 1 " 0 by default, compact folders that only contain a single folder into one node in the file tree
let g:nvim_tree_disable_window_picker = 1 "0 by default, will disable the window picker.
let g:nvim_tree_icon_padding = ' ' "one space by default, used for rendering the space between the icon and the filename. Use with caution, it could break rendering if you set an empty string depending on your font.
let g:nvim_tree_symlink_arrow = ' >> ' " defaults to ' ➛ '. used as a separator between symlinks' source and target.
let g:nvim_tree_respect_buf_cwd = 1 "0 by default, will change cwd of nvim-tree to that of new buffer's when opening nvim-tree.
let g:nvim_tree_create_in_closed_folder = 0 "1 by default, When creating files, sets the path of a file when cursor is on a closed folder to the parent folder when 0, and inside the folder when 1.
let g:nvim_tree_window_picker_exclude = {
    \   'filetype': [
    \     'notify',
    \     'packer',
    \     'qf'
    \   ],
    \   'buftype': [
    \     'terminal'
    \   ]
    \ }
" Dictionary of buffer option names mapped to a list of option values that
" indicates to the window picker that the buffer's window should not be
" selectable.
let g:nvim_tree_special_files = { 'README.md': 1, 'Makefile': 1, 'MAKEFILE': 1 } " List of filenames that gets highlighted with NvimTreeSpecialFile
let g:nvim_tree_show_icons = {
    \ 'git': 1,
    \ 'folders': 0,
    \ 'files': 0,
    \ 'folder_arrows': 0,
    \ }
"If 0, do not show the icons for one of 'git' 'folder' and 'files'
"1 by default, notice that if 'files' is 1, it will only display
"if nvim-web-devicons is installed and on your runtimepath.
"if folder is 1, you can also tell folder_arrows 1 to show small arrows next to the folder icons.
"but this will not work when you set indent_markers (because of UI conflict)

" default will show icon by default if no icon is provided
" default shows no icon by default
let g:nvim_tree_icons = {
    \ 'default': '',
    \ 'symlink': '',
    \ 'git': {
    \   'unstaged': "✗",
    \   'staged': "✓",
    \   'unmerged': "",
    \   'renamed': "➜",
    \   'untracked': "★",
    \   'deleted': "",
    \   'ignored': "◌"
    \   },
    \ 'folder': {
    \   'arrow_open': "",
    \   'arrow_closed': "",
    \   'default': "",
    \   'open': "",
    \   'empty': "",
    \   'empty_open': "",
    \   'symlink': "",
    \   'symlink_open': "",
    \   }
    \ }

" nnoremap <C-b> :NvimTreeToggle<CR>
" nnoremap <leader>r :NvimTreeRefresh<CR>
nnoremap <C-b> :NvimTreeFindFile<CR>
" NvimTreeOpen, NvimTreeClose, NvimTreeFocus, NvimTreeFindFileToggle, and NvimTreeResize are also available if you need them

set termguicolors " this variable must be enabled for colors to be applied properly

" a list of groups can be found at `:help nvim_tree_highlight`
highlight NvimTreeFolderIcon guibg=blue

lua << EOF
require'nvim-tree'.setup {
  disable_netrw        = true,
  hijack_netrw         = true,
  open_on_setup        = false,
  ignore_ft_on_setup   = {},
  auto_close           = false,
  auto_reload_on_write = true,
  open_on_tab          = false,
  hijack_cursor        = false,
  update_cwd           = false,
  hijack_directories   = {
    enable = true,
    auto_open = true,
  },
  diagnostics = {
    enable = false,
    icons = {
      hint = "",
      info = "",
      warning = "",
      error = "",
    }
  },
  update_focused_file = {
    enable      = false,
    update_cwd  = false,
    ignore_list = {}
  },
  system_open = {
    cmd  = nil,
    args = {}
  },
  filters = {
    dotfiles = false,
    custom = {}
  },
  git = {
    enable = true,
    ignore = true,
    timeout = 500,
  },
  view = {
    width = 30,
    height = 30,
    hide_root_folder = false,
    side = 'left',
    auto_resize = false,
    mappings = {
      custom_only = false,
      list = {}
    },
    number = false,
    relativenumber = false,
    signcolumn = "yes"
  },
  trash = {
    cmd = "trash",
    require_confirm = true
  },
  actions = {
    change_dir = {
      global = false,
    },
    open_file = {
      quit_on_open = false,
    }
  }
}
EOF

require("options")
require("keymaps")

vim.cmd([[
" syntax on
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

let g:gruvbox_contrast_dark = 'hard'
let g:gruvbox_invert_selection = '0'
colorscheme gruvbox

autocmd FileType python
            \ nnoremap <buffer><silent><leader>l "lyiwoSyncLog.info("***AtulLog <C-R>l: %s", <C-R>l)<Esc> |
            \ vnoremap <buffer><silent><leader>l "lyoSyncLog.info("***AtulLog <C-R>l: %s", <C-R>l)<Esc> 
autocmd FileType javascript
            \ nnoremap <buffer><silent><leader>l "lyiwoconsole.info(<C-R>l);<Esc> |
            \ vnoremap <buffer><silent><leader>l "lyoconsole.info(<C-R>l);<Esc>

augroup highlight_yank
autocmd!
au TextYankPost * silent! lua vim.highlight.on_yank({higroup="Visual", timeout=200})
augroup END


" Snippets mapping
" Expand or jump
imap <expr> <C-l>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'
imap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : pumvisible() ? "\<C-n>" : '<Tab>'
imap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : pumvisible() ? "\<C-p>" : '<S-Tab>'

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
]])
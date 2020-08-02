syntax on
let &t_ti.="\e[1 q"
let &t_SI.="\e[5 q"
let &t_EI.="\e[1 q"
let &t_te.="\e[0 q"

set number
set relativenumber
set incsearch
set undodir=~/.vim/undodir
set undofile

" mappings
imap jj <Esc>

call plug#begin('~/.config/nvim/plugged')
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'gruvbox-community/gruvbox'
Plug 'haya14busa/vim-easymotion'
Plug 'pangloss/vim-javascript'
Plug 'yuezk/vim-js'
Plug 'maxmellon/vim-jsx-pretty'

call plug#end()

colorscheme gruvbox
set background=dark
set smartindent
set tabstop=4
set shiftwidth=4
set expandtab

" augroup javascript_folding
"    au!
"    au FileType javascript setlocal foldmethod=syntax
"augroup END

let g:fzf_layout = { 'window': { 'width': 0.8, 'height': 0.8 } }
let $FZF_DEFAULT_OPTS='--reverse'
let mapleader=" "
nnoremap <SPACE> <Nop>
noremap <C-P> :GFiles! --cached --others --exclude-standard<CR>

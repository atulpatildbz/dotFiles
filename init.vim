syntax on
let &t_ti.="\e[1 q"
let &t_SI.="\e[5 q"
let &t_EI.="\e[1 q"
let &t_te.="\e[0 q"

set number
set relativenumber
set incsearch
set clipboard=unnamed
set undodir=~/.vim/undodir
set undofile

" mappings
imap jj <Esc>
call plug#begin('~/.vim/plugged')
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'ryanoasis/vim-devicons'
Plug 'airblade/vim-gitgutter'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'scrooloose/nerdcommenter'
Plug 'morhetz/gruvbox'
Plug 'HerringtonDarkholme/yats.vim' " TS Syntax
"Plug 'haya14busa/vim-easymotion'
Plug 'easymotion/vim-easymotion'
Plug 'pangloss/vim-javascript'
Plug 'maxmellon/vim-jsx-pretty'
Plug 'tpope/vim-surround'
Plug 'vim-airline/vim-airline'
Plug 'unkiwii/vim-nerdtree-sync'
Plug 'brooth/far.vim'
Plug 'jremmen/vim-ripgrep'
Plug 'jmcantrell/vim-virtualenv'
Plug 'ThePrimeagen/vim-be-good', {'do': './install.sh'}
" Initialize plugin system
call plug#end()
"call plug#begin('~/.vim/plugged')
"Plug 'yuezk/vim-js'
"call plug#end()

colorscheme gruvbox
set background=dark
set smartindent
set tabstop=4
set shiftwidth=4
set expandtab

command! -nargs=0 Prettier :call CocAction('runCommand', 'prettier.formatFile')
" coc config
let g:coc_global_extensions = [
  \ 'coc-snippets',
  \ 'coc-pairs',
  \ 'coc-tsserver',
  \ 'coc-eslint', 
  \ 'coc-prettier', 
  \ 'coc-json', 
  \ ]
let g:python3_host_prog="C:\\Users\\atul.patil\\AppData\\Local\\Programs\\Python\\Python38-32\\python.exe"
let g:python_host_prog="C:\\Python27\\python.exe"
let g:UltiSnipsExpandTrigger="<C-l>"

" from readme
" if hidden is not set, TextEdit might fail.
set hidden " Some servers have issues with backup files, see #649 set nobackup set nowritebackup " Better display for
"messages set cmdheight=2 " You will have bad experience for
"diagnostic messages when it's default 4000.
set updatetime=300

" augroup javascript_folding
"    au!
"    au FileType javascript setlocal foldmethod=syntax
"augroup END

let g:fzf_layout = { 'window': { 'width': 0.8, 'height': 0.8 } }
let $FZF_DEFAULT_OPTS='--reverse'
let mapleader=" "
let g:NERDTreeIgnore = ['^node_modules$']


nnoremap <SPACE> <Nop>
noremap <C-P> :GFiles! --cached --others --exclude-standard <CR>
"noremap <C-I> :GFiles! --cached --others --exclude-standard -i <CR>
map! <S-Insert> <C-R>+


" Use tab for trigger completion with characters ahead and navigate.
" " Use command ':verbose imap <tab>' to make sure tab is not mapped by other
" plugin.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Remap keys for gotos
if !exists('g:vscode')
    " VSCode related settings"
    nmap <silent> gd <Plug>(coc-definition)
    nmap <silent> gy <Plug>(coc-type-definition)
    nmap <silent> gi <Plug>(coc-implementation)
    nmap <silent> gr <Plug>(coc-references)
    nmap <F2> <Plug>(coc-rename)
    inoremap <silent><expr> <c-space> coc#refresh()
endif
nnoremap <silent> K :call <SID>show_documentation()<CR>
"split navigations
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Use K to show documentation in preview window
function! s:show_documentation()
    if (index(['vim','help'], &filetype) >= 0)
        execute 'h '.expand('<cword>')
    else
        call CocAction('doHover')
    endif
endfunction


" Remap for format selected region
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)



let g:prettier#autoformat = 1
let g:prettier#autoformat_require_pragma = 0

"autocmd BufWritePre *.js,*.css :Prettier
nnoremap <Leader>v :e $MYVIMRC<cr>

" root patterns for python
autocmd FileType python let b:coc_root_patterns = ['.git', '.env', 'src', 'oracleproduct']


"----------------------------- NERDtree
"----------------------------------------

" Toggle NERDTree
nmap <C-b> :NERDTreeToggle<CR>
nmap <C-/>   <Plug>NERDCommenterToggle

let g:NERDTreeShowHidden = 1
let g:NERDTreeMinimalUI = 1
let g:NERDTreeIgnore = []
let g:NERDTreeStatusline = ''
" Automaticaly close nvim if NERDTree is only thing left open
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
" sync open file with NERDTree
" " Check if NERDTree is open or active
function! IsNERDTreeOpen()
    return exists("t:NERDTreeBufName") && (bufwinnr(t:NERDTreeBufName) != -1)
endfunction

" Call NERDTreeFind iff NERDTree is active, current window contains a
" modifiable
" file, and we're not in vimdiff
function! SyncTree()
    if &modifiable && IsNERDTreeOpen() && strlen(expand('%')) > 0 && !&diff
        NERDTreeFind
        wincmd p
    endif
endfunction

" Highlight currently open buffer in NERDTree
autocmd BufEnter * call SyncTree()

" fix imports on python file open
" this is needed because there isn't a way to set multiple source root like
" it is in pycharm
function! FixPythonImport()
    :silent! %s/from inSyncLib/from src.inSyncLib/gI
    :silent! %s/from roboWWWLib/from src.cportal.cportalserver.roboWWWLib/gI
    :silent! %s/from roboPanel/from src.cportal.cportalserver.roboPanel/gI
    :silent! %s/from roboLib/from src.roboCloud.roboLib/gI
    :silent! %s/from oracleproduct/from src.oracleproduct/gI
endfunction
au BufReadPost *.py call FixPythonImport()

function! SaveFile()
    if (index(['python'], &filetype) >= 0)
        :silent! %s/from src.inSyncLib/from inSyncLib/gI
        :silent! %s/from src.cportal.cportalserver.roboWWWLib/from roboWWWLib/gI
        :silent! %s/from src.cportal.cportalserver.roboPanel/from roboPanel/gI
        :silent! %s/from src.roboCloud.roboLib/from roboLib/gI
        :silent! %s/from src.oracleproduct/from oracleproduct/gI
        w!
        :silent! %s/from inSyncLib/from src.inSyncLib/gI
        :silent! %s/from roboWWWLib/from src.cportal.cportalserver.roboWWWLib/gI
        :silent! %s/from roboPanel/from src.cportal.cportalserver.roboPanel/gI
        :silent! %s/from roboLib/from src.roboCloud.roboLib/gI
        :silent! %s/from oracleproduct/from src.oracleproduct/gI
    else
        w!
    endif
endfunction
nnoremap <leader>w :call SaveFile() <CR>
nnoremap <leader>q :q! <CR>

nnoremap <leader>cr :CocRestart <CR>

nnoremap <leader>f :Rg <C-R><C-W> -g *.
nnoremap <leader>b :Buf <CR>




let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#buffer_nr_show = 1

imap <C-j> <Plug>(coc-snippets-expand-jump)

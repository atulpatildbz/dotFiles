require("custom_functions")
require("options")
require("keymaps")
require("plugins")
require("autocmd")
require("colorscheme_config")

-- plugins specific settings
require("_completion")
require("lsp")
require("treesitter")
require("statusbar")
require("_gitsigns")
require("formatter_config")
require("nvim-tree_config")
require("toggleTerm_config")
require("hop_config")
require("spectre_config")

vim.cmd[[
" When using `dd` in the quickfix list, remove the item from the quickfix list.
function! RemoveQFItem()
  let curqfidx = line('.') - 1
  let qfall = getqflist()
  call remove(qfall, curqfidx)
  call setqflist(qfall, 'r')
  execute curqfidx + 1 . "cfirst"
  :copen
endfunction
:command! RemoveQFItem :call RemoveQFItem()
" Use map <buffer> to only map dd in the quickfix window. Requires +localmap
autocmd FileType qf map <buffer> dd :RemoveQFItem<cr>
]]

-- command "GitDiffToFiles" should execute the following commands
-- :v/diff --git/d
-- :%s/diff --git a\/
-- :%s/ .*
-- :sort u
vim.cmd[[
function! GitDiffToFiles()
    :silent v/diff --git/d
    :silent %s/diff --git a\/
    :silent %s/ .*
    :silent sort u
endfunction
:command! GitDiffToFiles :call GitDiffToFiles()
]]

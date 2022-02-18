vim.cmd[[
autocmd FileType python
            \ nnoremap <buffer><silent><leader>l "lyiwoSyncLog.info("***AtulLog <C-R>l: %s", <C-R>l)<Esc> |
            \ vnoremap <buffer><silent><leader>l "lyoSyncLog.info("***AtulLog <C-R>l: %s", <C-R>l)<Esc> 
]]
vim.cmd[[
autocmd FileType javascript
            \ nnoremap <buffer><silent><leader>l "lyiwoconsole.info(<C-R>l);<Esc> |
            \ vnoremap <buffer><silent><leader>l "lyoconsole.info(<C-R>l);<Esc>
]]

vim.cmd[[
augroup highlight_yank
    autocmd!
    au TextYankPost * silent! lua vim.highlight.on_yank({higroup="Visual", timeout=200})
augroup END
]]

local options = {
    -- boolean
    relativenumber = true,
    nu = true,
    hidden = true,
    errorbells = false,
    expandtab = true,
    smartindent = true,
    smartcase = true,
    ignorecase = true,
    swapfile = false,
    backup = false,
    undofile = true,
    incsearch = true,
    cursorline = true,
    termguicolors = true,                                -- this variable must be enabled for colors to be applied properly
    -- number
    tabstop = 4,
    softtabstop = 4,
    shiftwidth = 4,
    -- string
    -- mouse = "a",
    background = "dark",
    undodir = "~/.nvim/undodir",
    signcolumn = "yes",
    clipboard = "unnamed",
    -- table
    completeopt = { "menuone", "noinsert", "noselect"},  -- Set completeopt to have a better completion experience
}

vim.opt.shortmess:append "c"                            -- Avoid showing message extra message when using completion

-- for each key and value in options, set vim.opt[key] to value
for key, value in pairs(options) do
    vim.opt[key] = value
end

vim.g.fzf_preview_window = ""

-- overwriting these values by adding extra <Leader> so that it doesn't get in the way of showing buffer keymapping
vim.g.neomux_yank_buffer_map = "<Leader><Leader>by"
vim.g.neomux_paste_buffer_map = "<Leader><Leader>bp"

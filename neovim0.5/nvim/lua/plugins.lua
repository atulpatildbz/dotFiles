local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
 PACKER_BOOTSTRAP = fn.system {
   "git",
   "clone",
   "--depth",
   "1",
   "https://github.com/wbthomason/packer.nvim",
   install_path,
 }
 -- print the install path
 print(install_path)
 vim.cmd [[packadd packer.nvim]]
end

-- Autocommand that reloads the neovim whenever you save this file
-- vim.cmd [[
    -- augroup packer_user_config
        -- autocmd!
        -- autocmd BufWritePost plugins.lua source <afile> | PackerSync
    -- augroup end
-- ]]

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
    return
end

-- Have packer use a popup window
packer.init {
    display = {
        open_fn = function()
            return require("packer.util").float { border = "rounded" }
        end,
    },
}

-- Install your plugins here
return packer.startup(function(use)
  -- My plugins here
    use 'nvim-lua/plenary.nvim'
    use 'nvim-lua/popup.nvim'
    use 'nvim-telescope/telescope.nvim'
    use {'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
    use 'neovim/nvim-lspconfig'
    use 'williamboman/nvim-lsp-installer'
    use {
      'glepnir/lspsaga.nvim',
        branch = 'main',
    }

    use 'hrsh7th/cmp-buffer'
    use 'hrsh7th/cmp-cmdline'
    use 'hrsh7th/cmp-nvim-lsp'
    use 'hrsh7th/cmp-nvim-lua'
    use 'hrsh7th/cmp-path'
    use 'hrsh7th/cmp-vsnip'
    use 'hrsh7th/nvim-cmp'
    use 'hrsh7th/vim-vsnip'
    use 'hrsh7th/vim-vsnip-integ'

    use {'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'}
    use 'nvim-treesitter/nvim-treesitter-textobjects'

    use {
      'nvim-lualine/lualine.nvim',
      requires = { 'kyazdani42/nvim-web-devicons', opt = true }
    }
    use 'kyazdani42/nvim-web-devicons'
    use 'kyazdani42/nvim-tree.lua'

    use 'NLKNguyen/papercolor-theme'
    use 'nikvdp/neomux'

    use 'tpope/vim-ragtag'
    use 'tpope/vim-surround'
    use 'tpope/vim-unimpaired'

    use 'tpope/vim-eunuch'
    use 'tpope/vim-fugitive'

    use 'b3nj5m1n/kommentary'
    use 'lewis6991/gitsigns.nvim'
    -- use 'junegunn/fzf', { 'do': { -> fzf#install() } }
    use 'junegunn/fzf.vim'
    use 'nvim-lua/completion-nvim'

    use 'tjdevries/colorbuddy.vim'

    use 'folke/lsp-colors.nvim'
    use 'morhetz/gruvbox'
    use 'sainnhe/gruvbox-material'
    use 'tomasiser/vim-code-dark'
    use 'folke/tokyonight.nvim'
    use {
      'lourenci/github-colors',
        branch = 'main',
    }
    use 'sainnhe/sonokai'
    use 'mhartington/oceanic-next'
    use 'rockerBOO/boo-colorscheme-nvim'
    use 'tanvirtin/monokai.nvim'
    use 'sainnhe/everforest'
    use 'projekt0n/github-nvim-theme'

    use 'mhartington/formatter.nvim'
    use {'windwp/nvim-autopairs', config = "require('nvim-autopairs').setup{}"}
    use 'nvim-treesitter/playground'
    use 'github/copilot.vim'
    use 'David-Kunz/jester'
    -- use 'folke/tokyonight.nvim', { 'branch': 'main' }
    -- enable jsx pretty only if you're working with a colorscheme that doesn't have treesitter support
    -- use {'maxmellon/vim-jsx-pretty', ft = { 'javascript', 'javascriptreact' } }
    -- use 'justinmk/vim-sneak'
    use {'mustache/vim-mustache-handlebars', ft = 'handlebars'}
    use {'kevinhwang91/nvim-bqf'}
    use {"akinsho/toggleterm.nvim"}
    use "phaazon/hop.nvim"

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
 if PACKER_BOOTSTRAP then
   require("packer").sync()
 end
end)

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
  print "Installing packer close and reopen Neovim..."
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
    use 'glepnir/lspsaga.nvim'
    use 'hrsh7th/nvim-cmp'

    use 'hrsh7th/vim-vsnip'
    use 'hrsh7th/vim-vsnip-integ'

    use 'hrsh7th/cmp-buffer'

    use {'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'}
    use 'nvim-treesitter/nvim-treesitter-textobjects'

    use {
      'glepnir/galaxyline.nvim',
        branch = 'main',
        -- some optional icons
        requires = {'kyazdani42/nvim-web-devicons', opt = true}
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
    use {'morhetz/gruvbox', config= "vim.cmd('colorscheme gruvbox')" }
    use 'mhartington/formatter.nvim'
    use {'windwp/nvim-autopairs', config = "require('nvim-autopairs').setup{}"}
    use 'nvim-treesitter/playground'
    use 'github/copilot.vim'
    use 'David-Kunz/jester'
    -- use 'folke/tokyonight.nvim', { 'branch': 'main' }
    use 'maxmellon/vim-jsx-pretty'
    use 'justinmk/vim-sneak'
    use 'nono/vim-handlebars'

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if PACKER_BOOTSTRAP then
    require("packer").sync()
  end
end)

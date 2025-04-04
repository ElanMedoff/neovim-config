local h = require "shared.helpers"

local data_dir = vim.fn.stdpath "data"
if vim.fn.empty(vim.fn.glob(data_dir .. "/site/autoload/plug.vim")) == 1 then
  vim.cmd("silent !curl -fLo " ..
    data_dir ..
    "/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim")
  vim.o.runtimepath = vim.o.runtimepath
  vim.api.nvim_create_autocmd({ "VimEnter", }, {
    pattern = "*",
    callback = h.keys.vim_cmd_cb "PlugInstall --sync",
  })
end

local vim = vim
local Plug = vim.fn["plug#"]

vim.call "plug#begin"

-- (no file)
Plug "nvim-lua/popup.nvim"
Plug "nvim-lua/plenary.nvim"
Plug "tpope/vim-surround"
Plug "tpope/vim-repeat"
Plug "tpope/vim-commentary"
Plug "mg979/vim-visual-multi"
Plug "jxnblk/vim-mdx-js"
-- buffers
Plug "akinsho/bufferline.nvim"
-- colorscheme
Plug "RRethy/nvim-base16"
-- file_tree
Plug "stevearc/oil.nvim"
Plug "kyazdani42/nvim-web-devicons"
-- git
Plug "tpope/vim-fugitive"
Plug "lewis6991/gitsigns.nvim"
-- lsp
Plug "neovim/nvim-lspconfig"
Plug "hrsh7th/nvim-cmp"
Plug "hrsh7th/cmp-buffer"
Plug "hrsh7th/cmp-nvim-lsp"
Plug "hrsh7th/cmp-path"
Plug "williamboman/mason.nvim"
Plug "williamboman/mason-lspconfig.nvim"
Plug "folke/lazydev.nvim"
Plug "windwp/nvim-autopairs"
Plug "stevearc/conform.nvim"
-- movements
Plug("ThePrimeagen/harpoon", { branch = "harpoon2", })
Plug "folke/flash.nvim"
Plug "chentoast/marks.nvim"
Plug "christoomey/vim-tmux-navigator"
-- scroll
Plug "karb94/neoscroll.nvim"
Plug "echasnovski/mini.map"
-- statusline
Plug "nvim-lualine/lualine.nvim"
-- tele
Plug "nvim-telescope/telescope.nvim"
Plug("nvim-telescope/telescope-fzf-native.nvim", { ["do"] = "make", })
Plug "nvim-telescope/telescope-frecency.nvim"
-- treesitter
Plug("nvim-treesitter/nvim-treesitter", { ["do"] = h.keys.vim_cmd_cb "TSUpdate", })
Plug "nvim-treesitter/nvim-treesitter-textobjects"
Plug "stevearc/aerial.nvim"
Plug "MeanderingProgrammer/markdown.nvim"
Plug "RRethy/nvim-treesitter-endwise"
Plug "windwp/nvim-ts-autotag"
Plug "JoosepAlviste/nvim-ts-context-commentstring"
-- wild_menu
Plug "gelguy/wilder.nvim"
Plug "romgrk/fzy-lua-native"
-- far
Plug "MagicDuck/grug-far.nvim"
-- misc
Plug "folke/snacks.nvim"
Plug "mbbill/undotree"
Plug "sindrets/diffview.nvim"

vim.call "plug#end"

local base_lua_path = vim.fn.stdpath "config" .. "/lua"              -- ~/.config/nvim/lua/
local glob_path = base_lua_path .. "/feature_complete/plugins/*.lua" -- ~/.config/nvim/lua/feature_complete/plugins/*.lua
for _, path in pairs(vim.split(vim.fn.glob(glob_path), "\n")) do
  -- convert absolute filename to relative
  -- ~/.config/nvim/lua/feature_complete/plugins/*.lua -> feature_complete/plugins/*
  local relfilename = path:gsub(base_lua_path, ""):gsub(".lua", "")
  require(relfilename)
end

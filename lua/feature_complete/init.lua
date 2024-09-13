local data_dir = vim.fn.stdpath('data')
if vim.fn.empty(vim.fn.glob(data_dir .. '/site/autoload/plug.vim')) == 1 then
  vim.cmd('silent !curl -fLo ' ..
    data_dir ..
    '/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim')
  vim.o.runtimepath = vim.o.runtimepath
  vim.cmd('autocmd VimEnter * PlugInstall --sync | source $MYVIMRC')
end

-- An example of vim-plug section --------------------------------------------
local vim = vim
local Plug = vim.fn['plug#']

vim.call('plug#begin')

Plug("nvim-lua/popup.nvim")
Plug("nvim-lua/plenary.nvim")
Plug("RRethy/nvim-base16", { commit = "6ac181b" })
Plug("stevearc/aerial.nvim", { commit = "92f93f4" })
Plug("kevinhwang91/nvim-bqf", { commit = "1b24dc6" })
Plug("junegunn/fzf", { commit = "a09c6e9", ['do'] = "./install --bin" })
Plug("akinsho/bufferline.nvim", { commit = "0b2fd86", })
Plug("vim-scripts/BufOnly.vim", { cmd = "BufOnly", commit = "43dd923" })
Plug("neoclide/coc.nvim", { branch = "release", commit = "ae1a557", })
Plug("windwp/nvim-autopairs", { commit = "19606af", })
Plug("MeanderingProgrammer/markdown.nvim", { commit = "8c67dbc" })
Plug("numToStr/Comment.nvim", { commit = "e30b7f2", })
Plug("JoosepAlviste/nvim-ts-context-commentstring", { commit = "375c2d8" })
Plug("lewis6991/gitsigns.nvim", { commit = "899e993" })
Plug("ThePrimeagen/harpoon", { branch = "harpoon2", commit = "0378a6c", })
Plug("nvim-lualine/lualine.nvim", { commit = "b431d22" })
Plug("echasnovski/mini.map", { commit = "8baf542", })
Plug("christoomey/vim-tmux-navigator", { commit = "5b3c701" })
Plug("mg979/vim-visual-multi", { commit = "38b0e8d" })
Plug("easymotion/vim-easymotion", { commit = "b3cfab2" })
Plug("ggandor/leap.nvim", { commit = "c6bfb19", })
Plug("ggandor/flit.nvim", { commit = "1ef72de", })
Plug("chentoast/marks.nvim", { commit = "74e8d01", })
Plug("AckslD/nvim-neoclip.lua", { commit = "709c97f" })
Plug("karb94/neoscroll.nvim", { commit = "532dcc8" })
Plug("kyazdani42/nvim-web-devicons", { commit = "3722e3d" })
Plug("preservim/nerdtree", { commit = "9b465ac" })
Plug("stevearc/oil.nvim", { commit = "30e0438" })
Plug("nvim-telescope/telescope.nvim", { commit = "a0bbec2", })
Plug("nvim-telescope/telescope-fzf-native.nvim", { commit = "cf48d4d", ['do'] = 'Make' })
Plug("fannheyward/telescope-coc.nvim", { commit = "b305a2c" })
Plug("nvim-treesitter/nvim-treesitter-textobjects", { commit = "bf8d2ad" })
Plug("tpope/vim-surround")
Plug("tpope/vim-repeat")
Plug("tpope/vim-speeddating")
Plug("tpope/vim-fugitive")
Plug("windwp/nvim-ts-autotag", { commit = "e239a56" })
Plug("RRethy/nvim-treesitter-endwise", { commit = "8b34305" })
Plug("lukas-reineke/indent-blankline.nvim", { commit = "18603eb" })
Plug("nvim-treesitter/nvim-treesitter",
  {
    commit = "7a64148",
    -- https://github.com/rafamadriz/dotfiles/commit/c1268c73bdc7da52af0d57dcbca196ca3cb5ed79
    ['do'] = function() require("nvim-treesitter.install").update() end,
  }
)
Plug("folke/zen-mode.nvim", { commit = "29b292b" })
vim.call('plug#end')

local base_lua_path = vim.fn.stdpath('config') .. '/lua'             -- ~/.config/nvim/lua/
local glob_path = base_lua_path .. '/feature_complete/plugins/*.lua' -- ~/.config/nvim/lua/feature_complete/plugins/*.lua
for _, path in pairs(vim.split(vim.fn.glob(glob_path), '\n')) do
  -- convert absolute filename to relative
  -- ~/.config/nvim/lua/feature_complete/plugins/*.lua => feature_complete/plugins/*
  local relfilename = path:gsub(base_lua_path, ""):gsub(".lua", "")
  require(relfilename)
end

local h = require "shared.helpers"

-- remap leader before importing remaps that use it
h.keys.map({ "", }, "<space>", "<nop>")
h.let.mapleader = " "
h.let.maplocalleader = " "
vim.cmd "colorscheme slate"

require "shared.options"
require "shared.remaps"
require "shared.user_commands"
require "barebones"

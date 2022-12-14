package.path = package.path .. ";" .. os.getenv("HOME") .. "/.config/nvim/?.lua"

require("settings.plugins.packer")

require("settings.plugins.alpha")
require("settings.plugins.barbar")
require("settings.plugins.bqf")
require("settings.plugins.coc")
require("settings.plugins.comment")
require("settings.plugins.diffview")
require("settings.plugins.gitsigns")
require("settings.plugins.harpoon")
require("settings.plugins.indent")
require("settings.plugins.lightspeed")
require("settings.plugins.lualine")
require("settings.plugins.neoclip")
require("settings.plugins.nullls")
require("settings.plugins.scrollbar")
require("settings.plugins.telescope")
require("settings.plugins.toggleterm")
require("settings.plugins.tree")
require("settings.plugins.treesitter")

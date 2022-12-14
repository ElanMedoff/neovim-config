package.path = package.path .. ";" .. os.getenv("HOME") .. "/.config/nvim/?.lua"
local h = require("shared.helpers")

local ok, bufferline = pcall(require, 'bufferline')
if not ok then
  return
end

bufferline.setup({
  auto_hide = true,
  tabpages = false,
  minimum_padding = 3
})

h.nmap("H", "<cmd>BufferPrevious<cr>")
h.nmap("L", "<cmd>BufferNext<cr>")
h.nmap("<leader>tw", "<cmd>BufferClose<cr>")
h.nmap("<leader>to", "<cmd>BufferCloseAllButCurrent<cr>")
h.nmap("<leader>ta", "<cmd>BufferCloseAllButPinned<cr>") -- aka close all
h.nmap("<leader>ti", "<cmd>BufferPick<cr>")
h.nmap("<leader>tn", "<cmd>BufferMoveNext<cr>")
h.nmap("<leader>tp", "<cmd>BufferMovePrevious<cr>")

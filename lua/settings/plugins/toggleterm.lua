package.path = package.path .. ";../?.lua"
local h = require("settings.helpers")

local ok, toggleterm = pcall(require, "toggleterm")
if not ok then
  return
end

toggleterm.setup({})
h.map("", "<C-g>", ":ToggleTerm direction=horizontal<CR>")
vim.cmd([[
  autocmd TermEnter term://*toggleterm#* tnoremap <silent><C-g> <Cmd>exe v:count1 . "ToggleTerm"<CR>
]])

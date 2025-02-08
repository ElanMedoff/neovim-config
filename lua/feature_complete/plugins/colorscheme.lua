local base16 = require "base16-colorscheme"

-- tomorrow-night
local colors = {
  base00 = "#1d1f21",
  base01 = "#282a2e",
  base02 = "#373b41",
  base03 = "#969896",
  base04 = "#b4b7b4",
  base05 = "#c5c8c6",
  base06 = "#e0e0e0",
  base07 = "#ffffff",
  base08 = "#cc6666",
  base09 = "#de935f",
  base0A = "#f0c674",
  base0B = "#b5bd68",
  base0C = "#8abeb7",
  base0D = "#81a2be",
  base0E = "#b294bb",
  base0F = "#a3685a",
}
base16.setup(colors)

local M = {
  black = colors.base00,
  grey = colors.base02,
  light_grey = colors.base03,
  white = colors.base07,
  red = colors.base08,
  orange = colors.base09,
  yellow = colors.base0A,
  green = colors.base0B,
  cyan = colors.base0C,
  blue = colors.base0D,
  purple = colors.base0E,
  brown = colors.base0F,
}

vim.api.nvim_set_hl(0, "MatchParen", { fg = nil, bg = M.grey, })
vim.api.nvim_set_hl(0, "LspReferenceRead", { bg = "#2e3136", })  -- between base01 and base 02
vim.api.nvim_set_hl(0, "LspReferenceText", { bg = "#2e3136", })  -- between base01 and base 02
vim.api.nvim_set_hl(0, "LspReferenceWrite", { bg = "#2e3136", }) -- between base01 and base 02

vim.api.nvim_set_hl(0, "PmenuBorder", { fg = M.light_grey, })
vim.api.nvim_set_hl(0, "TelescopeBorder", { link = "PmenuBorder", })
vim.api.nvim_set_hl(0, "FloatBorder", { link = "PmenuBorder", }) -- harpoon border
vim.api.nvim_set_hl(0, "CursorLine", { link = "Visual", })
vim.api.nvim_set_hl(0, "AerialLine", { link = "Visual", })
vim.api.nvim_set_hl(0, "BufferLineBufferSelected", { fg = M.yellow, underline = true, bold = true, })
vim.api.nvim_set_hl(0, "WilderAccent", { fg = M.orange, })
vim.api.nvim_set_hl(0, "WildMenu", { fg = M.yellow, underline = true, bold = true, })

return M

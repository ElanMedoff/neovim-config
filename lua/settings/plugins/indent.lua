local indent = require "ibl"

local highlight = {
  "RainbowYellow",
  "RainbowRed",
  "RainbowBlue",
  "RainbowOrange",
  "RainbowGreen",
  "RainbowViolet",
  "RainbowCyan",
}
local hooks = require "ibl.hooks"
hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
  vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#e9989e" })
  vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#ecd2a2" })
  vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#90c7f3" })
  vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#deb893" })
  vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#b6d5a1" })
  vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#d7a0e7" })
  vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#88cbd4" })
end)

-- if turning rainbow_delimiters off, uncomment this
-- vim.cmd [[highlight IblIndent guifg=#363636]]
vim.cmd [[highlight IblIndent guifg=#484948]]

-- scope is overwritten by rainbow_delimiters
-- vim.cmd [[highlight IblScope guifg=#484948]]

indent.setup({
  scope = {
    highlight = highlight,
    show_start = false,
    show_end = false
  },
})

hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)

vim.g.rainbow_delimiters = {
  query = {
    [''] = 'rainbow-blocks',
  },
  highlight = highlight
}

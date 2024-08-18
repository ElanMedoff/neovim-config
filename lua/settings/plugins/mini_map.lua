local h = require "shared.helpers"
local mini_map = require "mini.map"

mini_map.setup({
  symbols = {
    encode = mini_map.gen_encode_symbols.dot("4x2"),
    scroll_line = "▶",
  }
})


-- TODO: find a better way to do this
local hide_mini = false

vim.api.nvim_create_autocmd({ "BufEnter" }, {
  pattern = "*",
  callback = function()
    print('Bufenter', hide_mini)
    if h.table_contains({ "oil" }, vim.bo.filetype) or hide_mini then
      require("mini.map").close()
    else
      require("mini.map").open()
    end
  end
})

vim.api.nvim_create_autocmd({ "TabEnter" }, {
  pattern = "*",
  callback = function()
    print('TabEnter')
    if vim.fn.winnr('$') > 2 then
      hide_mini = true
      require("mini.map").close()
    else
      hide_mini = false
      require("mini.map").open()
    end
  end
})

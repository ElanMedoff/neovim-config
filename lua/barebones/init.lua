local h = require "helpers"

-- https://github.com/neovim/neovim/issues/18000#issuecomment-1088700694
-- vim.opt.wildchar = ("<C-n>"):byte()
vim.cmd "set wildchar=<C-n>"

-- removing banner causes a bug where the terminal flickers
-- vim.g.netrw_banner = 0 -- removes banner at the top
-- vim.g.netrw_liststyle = 3 -- tree view
vim.g.netrw_liststyle = 0 -- tree view

vim.keymap.set("n", "<C-f>", function()
  if vim.bo.filetype == "netrw" then
    vim.cmd "Rex"
  else
    vim.cmd "Explore %:p:h"
  end
end, { desc = "Toggle netrw, focusing the current buffer", })

vim.keymap.set("n", "<C-p>", ":find<space>")

vim.opt.path:append "**" -- search in subdirectories
vim.keymap.set("n", "<leader>f", ":grep<space>")
vim.keymap.set("n", "<leader>a", ":grep<space>")
vim.keymap.set("n", "<leader>h", ":help<space>")
vim.keymap.set("n", "<leader>m", h.keys.vim_cmd_cb "marks")
vim.keymap.set("n", "<leader>l;", h.keys.vim_cmd_cb "history")
vim.keymap.set("n", "<leader>b", function()
  local buffers = vim.api.nvim_list_bufs()

  local items = {}
  for _, buf in ipairs(buffers) do
    if vim.api.nvim_buf_is_loaded(buf) then
      local name = vim.api.nvim_buf_get_name(buf)
      if name ~= "" and name ~= "[No Name]" then
        table.insert(items, { buf = buf, name = name, })
      end
    end
  end

  vim.ui.select(
    items,
    { prompt = "Select buffer:", format_item = function(item) return item.name end, },
    function(choice) if choice then vim.api.nvim_set_current_buf(choice.buf) end end
  )
end)

vim.keymap.set("c", "/", function()
  if vim.fn.wildmenumode() == 1 then
    return "<C-y>"
  else
    return "/"
  end
end, { expr = true, })

local qf_preview = require "homegrown_plugins.quickfix_preview.init"
qf_preview.setup {
  keymaps = {
    select_close_preview = "o",
    select_close_quickfix = "<cr>",
    toggle = "t",
    next = { key = "<C-n>", },
    prev = { key = "<C-p>", },
    cnext = { key = "]q", },
    cprev = { key = "[q", },
  },
  get_preview_win_opts = function()
    return { relativenumber = false, number = true, signcolumn = "no", cursorline = true, winblend = 5, }
  end,
  get_open_win_opts = function()
    return { border = "rounded", }
  end,
}

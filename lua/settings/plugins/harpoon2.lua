local h = require "shared.helpers"
-- local colors = require "settings.plugins.base16"
local harpoon = require("harpoon")

harpoon:setup({
  settings = {
    save_on_toggle = true,
  },
})
h.nmap("<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list(), { ui_max_width = 80 }) end,
  { desc = "Toggle the harpoon window" })
h.nmap("<leader>hn", function() harpoon:list():next({ ui_nav_wrap = true }) end,
  { desc = "Go to the next harpoon entry" })
h.nmap("<leader>hp", function() harpoon:list():prev({ ui_nav_wrap = true }) end,
  { desc = "Go to the prev harpoon entry" })
h.nmap("<leader>ha", function() harpoon:list():add() end, { desc = "Add a harpoon entry" })

-- vim.api.nvim_set_hl(0, 'FloatBorder', { fg = colors.orange, bg = colors.black })

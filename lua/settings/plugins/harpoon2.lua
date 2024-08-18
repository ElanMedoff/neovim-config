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
h.nmap("<leader>aa", function() harpoon:list():add() end, { desc = "Add a hArpoon entry" })

-- vim.api.nvim_set_hl(0, 'FloatBorder', { fg = colors.orange, bg = colors.black })

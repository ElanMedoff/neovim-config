local h = require "shared.helpers"
local oil = require "oil"

oil.setup({
  default_file_explorer = true,
  delete_to_trash = true,
  view_options = {
    show_hidden = true
  },
  use_default_keymaps = false,
  keymaps = {
    ["g?"] = "actions.show_help",
    ["<cr>"] = "actions.select",
    ["<C-f>"] = "actions.close",
    ["-"] = "actions.parent",
    ["g."] = "actions.toggle_hidden",
  },
})
h.nmap("<C-f>", h.user_cmd_cb("Oil"), { desc = "Toggle oil" })
h.nmap("<leader>r", function() error "use `<C-f>` instead!" end)

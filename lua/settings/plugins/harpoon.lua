local h = require "shared/helpers"

local harpoon = require "harpoon"
harpoon.setup({})

h.nmap("<leader>aa", [[<cmd>lua require("harpoon.mark").add_file()<cr>]])
h.nmap("<leader>at", [[<cmd>lua require("harpoon.ui").toggle_quick_menu()<cr>]])
h.nmap("<leader>an", [[<cmd>lua require("harpoon.ui").nav_next()<cr>]])
h.nmap("<leader>ap", [[<cmd>lua require("harpoon.ui").nav_prev()<cr>]])

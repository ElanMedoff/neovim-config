local h = require "shared.helpers"

h.nmap("L", h.user_cmd_cb("bnext"), { desc = "Next buffer" })
h.nmap("H", h.user_cmd_cb("bprev"), { desc = "Previous buffer" })
h.nmap("<leader>tw", h.user_cmd_cb("bdelete"), { desc = "Close the current buffer" })
h.nmap("<leader>ta", function()
  vim.cmd("bufdo")
  vim.cmd("bdelete")
end, { desc = "Close all buffers" })
h.nmap("<C-f>", function()
  if vim.bo.filetype == "netrw" then
    vim.cmd("Rex")
  else
    vim.cmd("Explore %:p:h")
  end
end, { desc = "Toggle netrw, focusing the current file" })

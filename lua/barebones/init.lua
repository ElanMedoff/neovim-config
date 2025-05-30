local h = require "shared.helpers"

-- https://github.com/neovim/neovim/issues/18000#issuecomment-1088700694
-- vim.opt.wildchar = ("<C-n>"):byte()
vim.cmd "set wildchar=<C-s>"

-- removing banner causes a bug where the terminal flickers
-- vim.g.netrw_banner = 0 -- removes banner at the top
vim.g.netrw_liststyle = 3 -- tree view
vim.keymap.set("n", "<C-f>", function()
  if vim.bo.filetype == "netrw" then
    vim.cmd "Rex"
  else
    vim.cmd "Explore %:p:h"
  end
end, { desc = "Toggle netrw, focusing the current buffer", })

vim.keymap.set("n", "<C-p>", function() h.notify.warn "Exit and use fzf instead" end)

vim.opt.path:append "**" -- search in subfolder
vim.keymap.set("n", "<leader>f", "<C-o>:grep<space>")
vim.keymap.set("n", "<leader>a", "<C-o>:grep<space>")
vim.keymap.set("n", "<leader>h", "<C-o>:h<space>")
vim.keymap.set("n", "<leader>m", h.keys.vim_cmd_cb "marks")
vim.keymap.set("n", "<leader>b", h.keys.vim_cmd_cb "buffers")

vim.keymap.set("c", "/", function()
  if vim.fn.wildmenumode() == 1 then
    return "<C-y>"
  else
    return "/"
  end
end, { expr = true, })

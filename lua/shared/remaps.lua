local h = require "shared.helpers"

h.nmap("<leader>af", "<C-6>") -- alternate file
h.nmap("J", "gJ")             -- J without whitespace
h.nmap("<leader>o", "o<esc>")
h.nmap("<leader>O", "O<esc>")
h.nmap("<leader>rr", [[viw"_dP]])
h.nmap("<leader>r;", "@:")          -- repeat last command
h.nmap([[<leader>']], [["]])        -- for setting register
h.nmap("<leader>vs", "<cmd>vsplit<cr>")
h.nmap("<leader>p", "<cmd>pu<cr>")  -- paste on line below
h.nmap("<leader>P", "<cmd>pu!<cr>") -- paste on line above
h.nmap("<bs>", "b")

-- duplicate lines
h.nmap("<leader>dl", "yyp")
h.vmap("<leader>dl", "y`>p") -- move to end of selection, then yank

h.nmap("<leader>s", "<cmd>w<cr>")
h.nmap("<leader>w", "<cmd>q<cr>")
h.nmap("<leader>q", "<cmd>qa<cr>")

-- copy path of file
h.nmap("<leader>ip", [[<cmd>let @+ = expand("%:p")<cr>]])

-- keeps lines highlighted while indenting
h.vmap("<", "<gv")
h.vmap(">", ">gv")

-- focusing
h.nmap("<leader>f", "<C-w>w") -- toggle
h.nmap("<leader>h", "<C-w>h") -- toggle
h.nmap("<leader>j", "<C-w>j") -- toggle
h.nmap("<leader>k", "<C-w>k") -- toggle
h.nmap("<leader>l", "<C-w>l") -- toggle

-- quickfix list
h.nmap("gn", "<cmd>Cnext<cr>zz")
h.nmap("gp", "<cmd>Cprev<cr>zz")
h.nmap("ge", "<cmd>copen 25<cr>")
h.nmap("gq", "<cmd>cclose<cr>")

-- move lines up and down with alt-j, alt-k
h.nmap("∆", ":m .+1<cr>==")
h.nmap("˚", ":m .-2<cr>==")
h.imap("∆", "<esc>:m .+1<cr>==gi")
h.imap("˚", "<esc>:m .-2<cr>==gi")
h.vmap("∆", ":m '>+1<cr>gv=gv")
h.vmap("˚", ":m '<-2<cr>gv=gv")

-- search case sensitive, whole word, and both
h.nmap('<leader>/c', '/\\C<left><left>')
h.nmap('<leader>/w', '/\\<\\><left><left>')
h.nmap('<leader>cw', '/\\<\\>\\C<left><left><left><left>')

-- keep search result in the middle of the page
h.nmap("n", "nzz")
h.vmap("n", "nzz")
h.nmap("N", "Nzz")
h.vmap("N", "Nzz")

-- prevent x, c from overwriting the clipboard
h.map("", "x", [["_x]])
h.map("", "X", [["_X]])
h.map("", "c", [["_c]])
h.map("", "C", [["_C]])


local function count_based_keymap(movement)
  local count = vim.v.count
  if count > 0 then
    return movement
  else
    return 'g' .. movement
  end
end

h.nmap('j', function() return count_based_keymap("j") end, { expr = true })
h.nmap('k', function() return count_based_keymap("k") end, { expr = true })

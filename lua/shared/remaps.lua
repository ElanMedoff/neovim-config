local h = require "shared.helpers"

-- delay when using h.keys.map
vim.cmd "inoremap <C-t> <C-o>:Snippet<space>"
h.keys.map({ "n", "v", }, "<C-t>", function() h.notify.error "snippets only supported in insert mode!" end)

h.keys.map("n", "<leader>va", "ggVG", { desc = "Select all", })
h.keys.map("n", "*", "*N")
h.keys.map("n", "<leader>f", "<C-w>w", { desc = "Toggle focus between windows", })
h.keys.map("n", "<leader>e", h.keys.vim_cmd_cb "e", { desc = "Reload buffer", })
h.keys.map("n", "<leader>vs", h.keys.vim_cmd_cb "vsplit")
h.keys.map("n", "<bs>", "b")

h.keys.map({ "i", }, "<C-e>", "<C-o>$")
h.keys.map({ "n", "v", }, "<C-e>", "$")

h.keys.map({ "i", }, "<C-a>", "<C-o>^")
h.keys.map({ "n", "v", }, "<C-a>", "^")

h.keys.map("n", "<leader>o", "o<esc>")
h.keys.map("n", "<leader>O", "O<esc>")

h.keys.map("n", "E", [[viw"_dP]], { desc = "pastE without overwriting the default register", }) -- TODO: find a better remap
h.keys.map("n", "<leader>p", h.keys.vim_cmd_cb "pu", { desc = "Paste on the line below", })
h.keys.map("n", "<leader>P", h.keys.vim_cmd_cb "pu!", { desc = "Paste on the line above", })

h.keys.map("n", "<leader>du", [["zyy"zp]], { desc = "Duplicate the current line", })
h.keys.map({ "v", }, "<leader>du", [["zy`>"zp]], { desc = "Duplicate the current line", }) -- move to end of selection, then yank

h.keys.map("n", "<leader>w", h.keys.vim_cmd_cb "w", { desc = "Save", })
h.keys.map("n", "<leader>q", h.keys.vim_cmd_cb "q", { desc = "Quit", })

h.keys.map("n", "<leader>ka", function() vim.fn.setreg("+", vim.fn.expand "%:p") end,
  { desc = "C(K)opy the absolute path of a file", })
h.keys.map("n", "<leader>kr", function() vim.fn.setreg("+", vim.fn.expand "%:~:.") end,
  { desc = "C(K)opy the relative path of a file", })
h.keys.map("n", "<leader>ko", function()
    local open_cmd = h.os.is_linux() and "xdg-open" or "open"
    vim.cmd("!" .. open_cmd .. " '" .. vim.fn.expand "%:p" .. "'")
  end,
  { desc = "Open a file", })

h.keys.map({ "v", }, "<", "<gv", { desc = "Outdent, while keeping selection", })
h.keys.map({ "v", }, ">", ">gv", { desc = "Indent, while keeping selection", })

--- @param try string
--- @param catch string
local function generate_circular_next_prev(try, catch)
  local success, _ = pcall(vim.cmd, try)
  if not success then
    pcall(vim.cmd, catch)
  end
end

vim.api.nvim_create_user_command("Cnext", function() generate_circular_next_prev("cnext", "cfirst") end, {})
vim.api.nvim_create_user_command("Cprev", function() generate_circular_next_prev("cprev", "clast") end, {})

h.keys.map("n", "J", h.keys.vim_cmd_cb "Cnext", { desc = "Move to the next item in the quickfix list", })
h.keys.map("n", "K", h.keys.vim_cmd_cb "Cprev", { desc = "Move to the prev item in the quickfix list", })
h.keys.map("n", "Z", "gJ", { desc = "J without whitespace", })

h.keys.map("n", "ge", h.keys.vim_cmd_cb "copen", { desc = "Open the quickfix list", })
h.keys.map("n", "gq", h.keys.vim_cmd_cb "cclose", { desc = "Close the quickfix list", })

h.keys.map("n", "gn", "gt", { desc = "Go to the next tab", })
h.keys.map("n", "gp", "gT", { desc = "Go to the prev tab", })

-- TODO: issues with mac
local alt_j = h.os.is_linux() and "<A-j>" or "∆"
local alt_k = h.os.is_linux() and "<A-k>" or "˚"

-- https://vim.fandom.com/wiki/Moving_lines_up_or_down
h.keys.map("n", alt_j, ":m .+1<cr>==", { desc = "Move line down", })
h.keys.map("n", alt_k, ":m .-2<cr>==", { desc = "Move line up", })
h.keys.map({ "i", }, alt_j, "<esc>:m .+1<cr>==gi", { desc = "Move line down", })
h.keys.map({ "i", }, alt_k, "<esc>:m .-2<cr>==gi", { desc = "Move line up", })
h.keys.map({ "v", }, alt_j, ":m '>+1<cr>gv=gv", { desc = "Move line down", })
h.keys.map({ "v", }, alt_k, ":m '<-2<cr>gv=gv", { desc = "Move line up", })

-- search Case sensitive, Whole word, and All
vim.cmd [[
  nnoremap <leader>/c /\C<left><left>
  nnoremap <leader>/w /\<\><left><left>
  nnoremap <leader>/a /\<\>\C<left><left><left><left>
]]
-- search without regex
vim.cmd [[
  nnoremap / /\V
]]
-- search and replace
vim.cmd [[
  nnoremap <leader>/s :%s/\<\>\C/<left><left><left><left><left>
]]
h.keys.map("n", "<leader>/t", h.keys.vim_cmd_cb "noh", { desc = "Turn off highlighting", })

h.keys.map({ "n", "v", }, "n", "nzz")
h.keys.map({ "n", "v", }, "N", "Nzz")

-- prevent x, c from overwriting the clipboard
h.keys.map({ "", }, "x", [["_x]])
h.keys.map({ "", }, "X", [["_X]])
h.keys.map({ "", }, "c", [["_c]])
h.keys.map({ "", }, "C", [["_C]])

local function count_based_keymap(movement)
  local count = vim.v.count
  if count > 0 then
    return movement
  else
    return "g" .. movement
  end
end

h.keys.map("n", "j", function() return count_based_keymap "j" end,
  { expr = true, desc = "j, but respect lines that wrap", })
h.keys.map("n", "k", function() return count_based_keymap "k" end,
  { expr = true, desc = "k, but respect lines that wrap", })

h.keys.map({ "n", "v", "i", }, "<C-y>", h.keys.vim_cmd_cb "tabclose", { desc = "Close the current tab", })
h.keys.map("n", "Y", h.keys.vim_cmd_cb "silent! bdelete!", { desc = "Close the current buffer", })
h.keys.map("n", "<leader>ta", h.keys.vim_cmd_cb "silent! bufdo bdelete", { desc = "Close all buffers", })
h.keys.map("n", "<leader>to", function()
  local cur_buf = vim.api.nvim_get_current_buf()

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf == cur_buf then
      goto continue
    elseif vim.api.nvim_get_option_value("modified", { buf = buf, }) then
      goto continue
    else
      vim.api.nvim_buf_delete(buf, { force = true, })
    end

    ::continue::
  end
end)

-- https://stackoverflow.com/a/9407015
local function next_closed_fold(dir)
  local view = vim.fn.winsaveview()
  local prev_line_num = 0
  local curr_line_num = view.lnum
  local is_open = true

  while curr_line_num ~= prev_line_num and is_open do
    h.keys.send_keys("n", "z" .. dir)
    prev_line_num = curr_line_num
    curr_line_num = vim.fn.line "."
    is_open = vim.fn.foldclosed(curr_line_num) < 0
  end

  if is_open then
    vim.fn.winrestview(view)
  end
end
h.keys.map("n", "zj", function() next_closed_fold "j" end)
h.keys.map("n", "zk", function() next_closed_fold "k" end)
h.keys.map("n", "zt", "za", { desc = "Toggle fold", })
h.keys.map("n", "zT", "zA", { desc = "Toggle fold", })
h.keys.map("n", "z?", function()
  h.notify.info "common fold commands: z{t,T,c,C,o,O,R(open all folds),M(close all folds)}"
end
, { desc = "Toggle fold", })

-- TODO: use more
h.keys.map({ "n", "v", }, "Q", "{")
h.keys.map({ "n", "v", }, "W", "}")

-- remaps to figure out in the future:
h.keys.map("n", "B", "<nop>", { desc = "TODO find a remap", })
h.keys.map("n", "<leader>;", "<nop>", { desc = "TODO find a remap", })
h.keys.map("n", "<leader>x", "<nop>", { desc = "TODO find a remap", })
h.keys.map("n", "<leader>b", "<nop>", { desc = "TODO find a remap", })
h.keys.map("n", "<leader>n", "<nop>", { desc = "TODO find a remap", })
h.keys.map("n", "<leader>,", "<nop>", { desc = "TODO find a remap", })
h.keys.map("n", "<leader>.", "<nop>", { desc = "TODO find a remap", })

local h = require "shared.helpers"

require "custom_plugins.quickfix_preview".setup()

--- @param str string
--- @param start string
local function starts_with(str, start)
  -- http://lua-users.org/wiki/StringRecipes
  return str:sub(1, #start) == start
end

--- @param item_text string
local function shorten_bufname(item_text)
  local cwd_name = vim.fn.getcwd()

  if starts_with(item_text, cwd_name) then
    local slash_offset = 1
    return item_text:sub(#cwd_name + 1 + slash_offset)
  end

  return item_text
end

vim.api.nvim_create_autocmd({ "BufEnter", }, {
  pattern = "*",
  callback = function()
    if vim.bo.filetype ~= "qf" then return end

    local qf_list = vim.fn.getqflist()

    if #qf_list > 100 then
      local truncated_list = {}
      for i = 1, 100 do
        truncated_list[i] = qf_list[i]
      end

      local replace = "r"
      vim.fn.setqflist(truncated_list, replace)
      h.notify.info "truncated the quickfix list to 100 items"
    end
  end,
})

vim.api.nvim_create_autocmd({ "FileType", }, {
  pattern = "*",
  callback = function()
    if vim.bo.filetype ~= "qf" then return end
    vim.wo.cursorline = false
  end,
})

vim.api.nvim_create_autocmd({ "FileType", }, {
  pattern = "qf",
  callback = function()
    vim.keymap.set("n", "gdu", function()
      vim.fn.setqflist(vim.fn.getqflist())
      h.notify.info "Created a new list!"
    end, { buffer = true, desc = "Duplicate the current quickfix list", })

    vim.keymap.set("n", "<cr>", function()
      local curr_line = vim.fn.line "."
      vim.cmd "cclose"
      vim.cmd("cc " .. curr_line)
    end, { buffer = true, desc = "Go to the file under the cursor and close the quickfix list", })

    vim.keymap.set("n", "<C-n>", function()
      vim.cmd "Cnext"
      vim.cmd "copen"
    end, { buffer = true, desc = "Go to the next file and keep the quickfix list open", })

    vim.keymap.set("n", "<C-p>", function()
      vim.cmd "Cprev"
      vim.cmd "copen"
    end, { buffer = true, desc = "Go to the prev file and keep the quickfix list open", })

    vim.keymap.set("n", ">", function()
      --- @diagnostic disable-next-line: param-type-mismatch
      local success = pcall(vim.cmd, "cnewer")
      if not success then
        h.notify.warn "No newer list!"
      end
    end, { buffer = true, desc = "Go to the next quickfix list", })

    vim.keymap.set("n", "<", function()
      --- @diagnostic disable-next-line: param-type-mismatch
      local success = pcall(vim.cmd, "colder")
      if not success then
        h.notify.warn "No older list!"
      end
    end, { buffer = true, desc = "Go to the pre quickfix list", })
  end,
})

vim.opt.quickfixtextfunc = "v:lua.GetQuickfixTextFunc"

--- @param num number
--- @param num_digits number
--- @param side 'left' | 'right'
local function pad_num(num, num_digits, side)
  if #tostring(num) >= num_digits then
    return tostring(num)
  end

  local num_spaces = num_digits - #tostring(num)
  if side == "left" then
    return string.rep(" ", num_spaces) .. tostring(num)
  end
  return tostring(num) .. string.rep(" ", num_spaces)
end

function _G.GetQuickfixTextFunc()
  local longest_bufname_len = 0
  local longest_row_len = 0
  local longest_col_len = 0
  local qf_list = vim.fn.getqflist()

  local items = {}
  for _, item in pairs(qf_list) do
    local curr_bufname = shorten_bufname(vim.fn.bufname(item.bufnr))
    if #curr_bufname > longest_bufname_len then
      longest_bufname_len = #curr_bufname
    end

    if #tostring(item.lnum) > longest_row_len then
      longest_row_len = #tostring(item.lnum)
    end

    if #tostring(item.col) > longest_col_len then
      longest_col_len = #tostring(item.col)
    end
  end

  local misc_win_padding = 10
  local win_width = vim.api.nvim_win_get_width(h.curr.window) - misc_win_padding

  for index, item in pairs(qf_list) do
    local curr_bufname = shorten_bufname(vim.fn.bufname(item.bufnr))
    local buffer_padding_right = longest_bufname_len - #curr_bufname
    local formatted_item =
        curr_bufname ..
        string.rep(" ", buffer_padding_right) ..
        " | " ..
        pad_num(item.lnum, longest_row_len, "left") ..
        ":" ..
        pad_num(item.col, longest_col_len, "right") ..
        " | " ..
        vim.fn.trim(item.text)

    if #formatted_item > win_width then
      formatted_item = string.sub(formatted_item, 1, win_width)
    end
    items[index] = formatted_item
  end

  return items
end

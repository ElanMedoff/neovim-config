local h = require "shared.helpers"

vim.api.nvim_create_autocmd({ "BufEnter", }, {
  pattern = "*",
  callback = function()
    if h.tbl.table_contains_value({ "qf", "aerial", "undotree", }, vim.bo.filetype) then
      h.set.cursorline = true
    else
      h.set.cursorline = false
    end
  end,
})

-- WIP: quickfix preview
-- TODO:
-- cursor move event

local preview_win_id = nil

local function maybe_close_preview()
  if preview_win_id ~= nil then
    if vim.api.nvim_win_is_valid(preview_win_id) then
      local force = true
      vim.api.nvim_win_close(preview_win_id, force)
    end
  end
end

local flash_highlight = function(buf_id, line_num)
  local col_start = 0
  local col_end = -1
  local namespace = vim.api.nvim_buf_add_highlight(buf_id, h.curr.namespace, "Visual", line_num - 1, col_start, col_end)

  local remove_highlight = function()
    local line_start = 0
    local line_end = -1
    pcall(vim.api.nvim_buf_clear_namespace, buf_id, namespace, line_start, line_end)
  end
  vim.defer_fn(remove_highlight, 300)
end

local function preview_qf_item(qf_win_id)
  qf_win_id = qf_win_id or vim.api.nvim_get_current_win()
  maybe_close_preview()

  local preview_height = 10

  --- @class vim.api.keyset.win_config
  local win_opts       = {
    relative = "win",
    win = qf_win_id,
    width = vim.api.nvim_win_get_width(h.curr.window),
    height = preview_height,
    -- row = qf_win_row - preview_height - 2,
    row = -1 * preview_height - 2,
    col = 1,
    border = "double",
    title = "Preview",
    title_pos = "center",
    focusable = false,
  }

  local curr_line      = vim.fn.line "."
  local qf_list        = vim.fn.getqflist()
  if h.tbl.size(qf_list) == 0 then return end

  local curr_qf_item = qf_list[curr_line]

  local enter_window = true
  preview_win_id     = vim.api.nvim_open_win(curr_qf_item.bufnr, enter_window, win_opts)
  vim.api.nvim_win_set_cursor(preview_win_id, { curr_qf_item.lnum, curr_qf_item.col, })
  flash_highlight(curr_qf_item.bufnr, curr_qf_item.lnum)

  vim.cmd "copen"
  vim.api.nvim_win_set_cursor(qf_win_id, { curr_line, 0, })
end

vim.api.nvim_create_autocmd({ "FileType", }, {
  pattern = "qf",
  callback = function()
    h.keys.map({ "n", }, "p", function()
      local curr_line = vim.fn.line "."
      preview_qf_item()
      vim.cmd("cc" .. curr_line)
      vim.cmd "copen"
    end, { buffer = true, })

    h.keys.map({ "n", }, "<cr>", function()
      local curr_line = vim.fn.line "."
      vim.cmd "cclose"
      maybe_close_preview()
      vim.cmd("cc" .. curr_line)
    end, { buffer = true, })

    h.keys.map({ "n", }, "o", function()
      local curr_line = vim.fn.line "."
      maybe_close_preview()
      vim.cmd("cc" .. curr_line)
    end, { buffer = true, })
  end,
})

h.keys.map({ "n", }, "ge", function()
  vim.cmd "copen"
  preview_qf_item()
end, { desc = "Open the quickfix list", })

h.keys.map({ "n", }, "gq", function()
  vim.cmd "cclose"
  maybe_close_preview()
end, { desc = "Close the quickfix list", })

h.set.quickfixtextfunc = "v:lua.GetQuickfixTextFunc"

--- @param num number
--- @param num_digits number
local function pad_num(num, num_digits)
  if #tostring(num) >= num_digits then
    return tostring(num)
  end

  local num_padding = num_digits - #tostring(num)
  return tostring(num) .. string.rep(" ", num_padding)
end

function _G.GetQuickfixTextFunc()
  local longest_filename_len = 0
  local longest_row_len = 0
  local longest_col_len = 0
  local qf_list = vim.fn.getqflist()

  local items = {}
  for _, item in pairs(qf_list) do
    local curr_bufname = vim.fn.bufname(item.bufnr)
    if #curr_bufname > longest_filename_len then
      longest_filename_len = #curr_bufname
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
    local curr_bufname = vim.fn.bufname(item.bufnr)
    local buffer_right_padding = longest_filename_len - #curr_bufname
    local formatted_item = curr_bufname ..
        string.rep(" ", buffer_right_padding) ..
        " || " ..
        pad_num(item.lnum, longest_row_len) ..
        pad_num(item.col, longest_col_len) .. " ||   " ..
        vim.fn.trim(item.text)

    if #formatted_item > win_width then
      formatted_item = string.sub(formatted_item, 1, win_width)
    end
    items[index] = formatted_item
  end

  return items
end

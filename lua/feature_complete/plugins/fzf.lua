local h = require "shared.helpers"
local grug = require "grug-far"
local fzf_lua = require "fzf-lua"
local simple_rg = require "homegrown_plugins.simple_rg"

local ignore_dirs = { "node_modules", ".git", "dist", }
local fd_cmd = "fd --type f"
for _, ignore_dir in pairs(ignore_dirs) do
  fd_cmd = fd_cmd .. " --exclude " .. ignore_dir
end

fzf_lua.setup {
  winopts = {
    preview = {
      default = "bat_native",
      border = "rounded",
    },
    border  = "none",
    width   = 1,
  },
  files = {
    hidden = false,
    git_icons = false,
    file_icons = false,
    cmd = fd_cmd,
  },
  fzf_opts = {
    ["--layout"] = "reverse-list",
    ["--cycle"] = true,
  },
  keymap = {
    builtin = { false, },
    fzf = {
      false,
      ["ctrl-a"] = "toggle-all",
      ["tab"] = "select+down",
      ["shift-tab"] = "up+deselect",
    },
  },
  actions = {
    files = {
      ["enter"] = fzf_lua.actions.file_edit_or_qf,
    },
  },
  marks = {
    marks = "%a",
  },
  fzf_colors = true,
}

local with_preview_opts = {
  winopts = {
    height = 1,
    preview = {
      layout   = "vertical",
      vertical = "up:35%",
    },
  },
}

--- @param cb function
local function with_preview_cb(cb)
  return function() cb(with_preview_opts) end
end

--- @param cb function
local function without_preview_cb(cb)
  local without_preview_opts = {
    previewer = false,
    winopts = {
      height = 0.5,
      row    = 1,
    },
  }
  return function() cb(without_preview_opts) end
end

vim.keymap.set("n", "<leader>lr", fzf_lua.resume, { desc = "Resume fzf-lua search", })
vim.keymap.set("n", "<leader>h", with_preview_cb(fzf_lua.helptags), { desc = "Search help tags with fzf", })
vim.keymap.set("n", "<leader>lh", function() h.notify.warn "use <leader>h instead!" end)
vim.keymap.set("n", "<leader>m", with_preview_cb(fzf_lua.marks), { desc = "Search help tags with fzf", })
vim.keymap.set("n", "<leader>lm", function() h.notify.warn "use <leader>m instead!" end)
vim.keymap.set("n", "<leader>l;", without_preview_cb(fzf_lua.command_history),
  { desc = "Search search history with fzf", })
vim.keymap.set("n", "<leader>b", with_preview_cb(fzf_lua.buffers),
  { desc = "Search currently open buffers with fzf", })
vim.keymap.set("n", "<leader>f",
  function()
    local opts = vim.tbl_deep_extend("error", { search = "", }, with_preview_opts)
    fzf_lua.grep(opts)
  end,
  { desc = "Live grep the entire project", })
vim.keymap.set("n", "<leader>lg", function() h.notify.warn "use <leader>f instead!" end)

-- https://github.com/ibhagwan/fzf-lua/wiki/Advanced#example-1-live-ripgrep
--- @param initial_query string
local function live_grep_with_args(initial_query)
  local opts = vim.tbl_deep_extend("error", {}, with_preview_opts)
  opts.git_icons = false
  opts.file_icons = false
  opts.actions = fzf_lua.defaults.actions.files
  opts.previewer = "bat_native"
  opts.fn_transform = function(x)
    return fzf_lua.make_entry.file(x, opts)
  end
  opts.query = initial_query
  opts.fzf_opts = { ["--multi"] = true, }

  -- found in the live_grep implementation, necessary to preview the correct section w/bats
  -- fzf-lua/lua/fzf-lua/providers/grep.lua
  opts = fzf_lua.core.set_fzf_field_index(opts)

  return fzf_lua.fzf_live(function(prompt)
    local cmd = simple_rg.construct_rg_cmd(prompt or "")
    if cmd then h.notify.doing(cmd) end
    return cmd
  end, opts)
end

vim.keymap.set("n", "<leader>a", function() live_grep_with_args "~" end)
vim.keymap.set("n", "<leader>la", function() h.notify.warn "use <leader>a instead!" end)
vim.keymap.set("v", "<leader>o",
  function()
    local require_visual_mode_active = true
    local visual_selection = grug.get_current_visual_selection(require_visual_mode_active)
    if visual_selection == "" then return end
    live_grep_with_args("~" .. visual_selection .. "~ ")
  end, { desc = "Grep the current word", })
vim.keymap.set("n", "<leader>o",
  function()
    live_grep_with_args("~" .. vim.fn.expand "<cword>" .. "~ ")
  end, { desc = "Grep the current visual selection", })
vim.keymap.set({ "n", "v", }, "<leader>lo", function() h.notify.warn "use <leader>o instead!" end)

local function get_stripped_filename()
  local filepath = vim.fn.expand "%:p"

  local stripped_start = filepath:match "wf_modules.*$"
  if not stripped_start then
    h.notify.warn "`wf_modules` not found in the filepath!"
    return nil
  end

  local stripped_filename = stripped_start:match "(.-)%..-$"
  return stripped_filename
end

vim.keymap.set("n", "<leader>le",
  function()
    local stripped_filename = get_stripped_filename()
    if stripped_filename == nil then return end

    live_grep_with_args("~" .. stripped_filename .. "~ ")
  end, { desc = "Grep the current file name starting with `wf_modules`", })

vim.keymap.set("n", "<leader>ye",
  function()
    local stripped_filename = get_stripped_filename()
    if stripped_filename == nil then return end

    vim.fn.setreg("+", stripped_filename)
  end, { desc = "Yank a file name starting with `wf_modules`", })

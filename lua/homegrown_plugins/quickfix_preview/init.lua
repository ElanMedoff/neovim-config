local helpers = require "homegrown_plugins.quickfix_preview.helpers"
local validate = require "homegrown_plugins.quickfix_preview.validator".validate
local union = require "homegrown_plugins.quickfix_preview.validator".union

local QuickfixPreview = require "homegrown_plugins.quickfix_preview.class"
local qf_preview = QuickfixPreview:new()

local M = {}

--- @type QuickfixPreviewOpenOpts
local setup_open_or_refresh_opts = {}

M.is_closed = function()
  return qf_preview:is_closed()
end

M.close = function()
  return qf_preview:close()
end

--- @param disabled boolean
M.set_preview_disabled = function(disabled)
  --- @type Schema
  local disabled_schema = { type = "boolean", }
  if not validate(disabled_schema, disabled) then
    vim.notify(
      string.format(
        "Malformed opts! Expected %s, received %s",
        vim.inspect(disabled_schema),
        vim.inspect(disabled)
      ),
      vim.log.levels.ERROR
    )
    return
  end

  return qf_preview:set_preview_disabled(disabled)
end

--- @param opts QuickfixPreviewOpenOpts | nil
M.open_or_refresh = function(opts)
  --- @type Schema
  local opts_schema = {
    type = "table",
    entries = {
      get_open_win_opts = { type = "function", optional = true, },
      get_preview_win_opts = { type = "function", optional = true, },

    },
    optional = true,
  }
  if not validate(opts_schema, opts) then
    vim.notify(
      string.format("Malformed opts! Expected %s, received %s", vim.inspect(opts_schema), vim.inspect(opts)),
      vim.log.levels.ERROR
    )
    return
  end

  local local_opts = helpers.default(opts, {})
  local merged_opts = vim.tbl_extend("force", setup_open_or_refresh_opts, local_opts)

  return qf_preview:open_or_refresh(merged_opts)
end

--- @class QuickfixPreviewOpts
--- @field get_preview_win_opts? fun(qf_item: QuickfixItem):vim.wo Options to apply to the preview window. Defaults to an empty table
--- @field get_open_win_opts? fun(qf_item):vim.api.keyset.win_config
--- @field keymaps? QuickfixPreviewKeymaps Keymaps, defaults to none

--- @class QuickfixPreviewKeymaps
--- @field toggle? string Toggle the quickfix preview
--- @field select_close_preview? string Open the file undor the cursor, keeping the quickfix list open
--- @field select_close_quickfix? string Open the file under the cursor, closing the quickfix list
--- @field next? QuickFixPreviewKeymapCircularOpts | string :cnext, preserving focus on the quickfix list
--- @field prev? QuickFixPreviewKeymapCircularOpts | string :cprev, preserving focus on the quickfix list
--- @field cnext? QuickFixPreviewKeymapCircularOpts | string :cnext, closing the preview first
--- @field cprev? QuickFixPreviewKeymapCircularOpts | string :cprev, closing the preview first

--- @class QuickFixPreviewKeymapCircularOpts
--- @field key string The key to set as the remap
--- @field circular? boolean Whether the next/prev command should circle back to the beginning/end. Defaults to `true`

--- @param opts QuickfixPreviewOpts | nil
M.setup = function(opts)
  --- @type Schema
  local circular_keymap_schema = {
    type = union {
      { type = "string", },
      {
        type = "table",
        entries = {
          key = { type = "string", },
          circular = { type = "boolean", optional = true, },
        },
        exact = true,
      },
    },
    optional = true,
  }

  --- @type Schema
  local opts_schema = {
    type = "table",
    entries = {
      get_preview_win_opts = { type = "function", optional = true, },
      get_open_win_opts = { type = "function", optional = true, },
      keymaps = {
        type = "table",
        optional = true,
        entries = {
          toggle = { type = "string", optional = true, },
          select_close_preview = { type = "string", optional = true, },
          select_close_quickfix = { type = "string", optional = true, },
          next = circular_keymap_schema,
          prev = circular_keymap_schema,
          cnext = circular_keymap_schema,
          cprev = circular_keymap_schema,
        },
        exact = true,
      },
    },
    optional = true,
    exact = true,
  }

  if not validate(opts_schema, opts) then
    vim.notify(
      string.format(
        "Malformed opts! Expected %s, received %s",
        vim.inspect(opts_schema),
        vim.inspect(opts)
      ),
      vim.log.levels.ERROR
    )
    return
  end

  opts = helpers.default(opts, {})
  setup_open_or_refresh_opts = {
    get_open_win_opts = opts.get_open_win_opts,
    get_preview_win_opts = opts.get_preview_win_opts,
  }
  local keymaps = helpers.default(opts.keymaps, {})


  vim.api.nvim_create_autocmd({ "CursorMoved", }, {
    callback = function()
      if vim.bo.buftype ~= "quickfix" then return end
      qf_preview:open_or_refresh(setup_open_or_refresh_opts)
    end,
  })

  vim.api.nvim_create_autocmd("WinClosed", {
    callback = function()
      if vim.bo.buftype ~= "quickfix" then return end
      qf_preview:close()
    end,
  })

  vim.api.nvim_create_autocmd({ "FileType", }, {
    callback = function()
      if vim.bo.buftype ~= "quickfix" then return end

      local function select_close_preview()
        local qf_item_index = vim.fn.line "."
        --- @type QuickfixItem
        local qf_item = vim.fn.getqflist()[qf_item_index]

        qf_preview:close()

        local main_win = helpers.find_main_window()
        if not main_win then
          vim.notify("Can't find a window!", vim.log.levels.ERROR)
          return
        end

        vim.api.nvim_set_current_win(main_win)
        vim.cmd("edit " .. vim.fn.fnameescape(vim.fn.bufname(qf_item.bufnr)))
        vim.api.nvim_win_set_cursor(0, { qf_item.lnum, qf_item.col - 1, })
        vim.fn.setqflist({}, "a", { ["idx"] = qf_item_index, })
      end

      if keymaps.select_close_preview then
        vim.keymap.set("n", keymaps.select_close_preview, function()
          select_close_preview()
        end, { buffer = true, desc = "Open the file undor the cursor, keeping the quickfix list open", })
      end

      if keymaps.select_close_quickfix then
        vim.keymap.set("n", keymaps.select_close_quickfix, function()
          select_close_preview()
          vim.cmd "cclose"
        end, { buffer = true, desc = "Open the file under the cursor, closing the quickfix list", })
      end

      if keymaps.toggle then
        vim.keymap.set("n", keymaps.toggle, function()
          if qf_preview:is_closed() then
            qf_preview:open_or_refresh(setup_open_or_refresh_opts)
            qf_preview:set_preview_disabled(false)
          else
            qf_preview:close()
            qf_preview:set_preview_disabled(true)
          end
        end, { buffer = true, desc = "Toggle the quickfix preview", })
      end

      if keymaps.next then
        local circular = helpers.default(keymaps.next.circular, true)

        vim.keymap.set("n", keymaps.next.key, function()
          local next_qf_index = helpers.get_next_qf_index(circular)
          if next_qf_index == nil then return end
          vim.fn.setqflist({}, "a", { ["idx"] = next_qf_index, })
        end, { buffer = true, desc = ":cnext, preserving focus on the quickfix list", })
      end

      if keymaps.prev then
        local circular = helpers.default(keymaps.prev.circular, true)

        vim.keymap.set("n", keymaps.prev.key, function()
          local prev_qf_index = helpers.get_prev_qf_index(circular)
          if prev_qf_index == nil then return end
          vim.fn.setqflist({}, "a", { ["idx"] = prev_qf_index, })
        end, { buffer = true, desc = ":cprev, preserving focus on the quickfix list", })
      end
    end,
  })

  if keymaps.cnext then
    local circular = helpers.default(keymaps.cnext.circular, true)

    vim.keymap.set("n", keymaps.cnext.key, function()
      qf_preview:close()
      if circular then helpers.try_catch("cnext", "cfirst") else vim.cmd "cnext" end
    end, { desc = ":cnext, closing the preview first", })
  end

  if keymaps.cprev then
    local circular = helpers.default(keymaps.cprev.circular, true)

    vim.keymap.set("n", keymaps.cprev.key, function()
      qf_preview:close()
      if circular then helpers.try_catch("cprev", "clast") else vim.cmd "cprev" end
    end, { desc = ":cprev, closing the preview first", })
  end
end

return M

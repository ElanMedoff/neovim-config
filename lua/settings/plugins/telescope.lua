package.path = package.path .. ";" .. os.getenv("HOME") .. "/.config/nvim/?.lua"
local h = require("shared.helpers")

local telescope_ok, telescope = pcall(require, "telescope")
if not telescope_ok then
  return
end
local actions_ok, actions = pcall(require, "telescope.actions")
if not actions_ok then
  return
end
local action_state_ok, action_state = pcall(require, "telescope.actions.state")
if not action_state_ok then
  return
end

local custom_actions = {}

function custom_actions.fzf_multi_select(prompt_bufnr)
  local function get_table_size(t)
    local count = 0
    for _ in pairs(t) do
      count = count + 1
    end
    return count
  end

  local picker = action_state.get_current_picker(prompt_bufnr)
  local num_selections = get_table_size(picker:get_multi_selection())

  if num_selections > 1 then
    actions.send_selected_to_qflist(prompt_bufnr)
    actions.open_qflist()
  else
    actions.file_edit(prompt_bufnr)
  end
end

telescope.setup({
  defaults = {
    layout_strategy = 'vertical',
    layout_config = {
      height = 0.95,
      width = 0.925,
      prompt_position = "bottom",
      preview_height = 0.4,
    },
    mappings = {
      n = {
        ["<cr>"] = custom_actions.fzf_multi_select,
        ["<C-c>"] = actions.close,
        ["gq"] = actions.close
      },
      i = {
        ["<cr>"] = custom_actions.fzf_multi_select,
        ["<tab>"] = actions.toggle_selection + actions.move_selection_next,
        ["<s-tab>"] = actions.toggle_selection + actions.move_selection_previous,
      }
    }
  },
})

telescope.load_extension('fzf')
telescope.load_extension('neoclip')

h.nmap('<C-p>', [[<cmd>lua require('telescope.builtin').find_files()<cr>]])
h.nmap("<leader>zf", [[<cmd>lua require('telescope.builtin').grep_string({ search = vim.fn.input("Grep For > ")})<cr>]]) -- enter before grep
h.nmap("<leader>zu", [[<cmd>lua require('telescope.builtin').resume()<cr>]])

h.nmap("<leader>zo", [[<cmd>lua require('telescope.builtin').grep_string()<cr>]]) -- grep over current word
-- TODO: convert over to lua functions
h.vmap("<leader>zo", [["zy<cmd>exec 'Telescope grep_string search=' . escape(@z, ' ')<cr>]]) -- grep over selection
h.nmap("<leader>zl", [[<cmd>lua require('telescope.builtin').current_buffer_fuzzy_find()<cr>]])

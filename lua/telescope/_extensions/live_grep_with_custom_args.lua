local pickers = require "telescope.pickers"
local telescope = require "telescope"
local conf = require "telescope.config".values
local finders = require "telescope.finders"
local make_entry = require "telescope.make_entry"

--- @param input table
--- @return string
local function dump(input)
  if type(input) == "table" then
    local str = "{ "
    for key, value in pairs(input) do
      if type(key) ~= "number" then key = '"' .. key .. '"' end
      str = str .. "[" .. key .. "] = " .. dump(value)
    end
    return str .. "} "
  else
    return tostring(input)
  end
end

--- @param input_str string
--- @return table
local function split(input_str)
  local tbl = {}
  for str in string.gmatch(input_str, "([^%s]+)") do
    table.insert(tbl, str)
  end
  return tbl
end


local setup_opts = {
  auto_quoting = true,
}

local live_grep_with_custom_args = function(opts)
  opts = opts or {}

  --- @param opts { str: string, include_tbl: table, negate_tbl: table }
  local function insert_flags(opts)
    local str, include_tbl, negate_tbl = opts.str, opts.include_tbl, opts.negate_tbl
    if str:sub(1, 1) == "!" then
      if #str > 1 then
        table.insert(negate_tbl, str:sub(2))
      end
    else
      table.insert(include_tbl, str)
    end
  end

  --- @param opts { dir_tbl: table, file_tbl: table, negate: boolean }
  local function construct_flag(opts)
    local dir_tbl, file_tbl, negate = opts.dir_tbl, opts.file_tbl, opts.negate
    local flag = ""
    if #dir_tbl > 0 then
      flag = flag .. "**/{" .. table.concat(dir_tbl, ",") .. "}/**"
    end

    if #file_tbl > 0 then
      if #dir_tbl > 0 then
        flag = flag .. "/"
      end
      flag = flag .. "*{" .. table.concat(file_tbl, ",") .. "}"
    end

    if #flag > 0 then
      if negate then
        flag = "!" .. flag
      end
      return { "-g", flag, }
    end

    return {}
  end

  --- @param prompt string
  local function parse_search(prompt)
    local search = ""
    local search_index = 1
    while search_index < (#prompt + 1) do
      if search_index == 1 then
        goto continue
      end

      if prompt:sub(search_index, search_index) == "~" then
        break
      end

      search = search .. prompt:sub(search_index, search_index)

      ::continue::
      search_index = search_index + 1
    end

    return { search = search, search_index = search_index, }
  end

  local entry_maker = make_entry.gen_from_vimgrep(setup_opts)

  local cmd_generator = function(prompt)
    if not prompt or prompt == "" then
      return nil
    end

    local parsing_file_flags = false
    local parsing_dir_flags = false

    local include_file_flags = {}
    local negate_file_flags = {}
    local include_dir_flags = {}
    local negate_dir_flags = {}
    local case_sensitive_flag = { "--ignore-case", }
    local whole_word_flag = { nil, }

    local parsed_search = parse_search(prompt)
    local search, search_index = parsed_search.search, parsed_search.search_index

    local flags_prompt = prompt:sub(search_index + 1)
    local split_flags_prompt = split(flags_prompt)

    local flags_index = 1
    while flags_index < (#split_flags_prompt + 1) do
      local flag_token = split_flags_prompt[flags_index]

      local is_last_char_space = flags_prompt:sub(#flags_prompt, #flags_prompt) == " "
      if flags_index == #split_flags_prompt and not is_last_char_space then
        -- avoid updating the telescope command
        return nil
      end

      if flag_token == "-c" then
        case_sensitive_flag = { "--case-sensitive", }
        goto continue
      end

      if flag_token == "-nc" then
        case_sensitive_flag = { "--ignore-case", }
        goto continue
      end

      if flag_token == "-w" then
        whole_word_flag = { "--word-regexp", }
        goto continue
      end

      if flag_token == "-nw" then
        whole_word_flag = { nil, }
        goto continue
      end

      if flag_token == "-f" then
        parsing_file_flags = true
        parsing_dir_flags = false
        goto continue
      end

      if flag_token == "-d" then
        parsing_dir_flags = true
        parsing_file_flags = false
        goto continue
      end

      if parsing_file_flags == true then
        insert_flags { str = flag_token, include_tbl = include_file_flags, negate_tbl = negate_file_flags, }
        goto continue
      end

      if parsing_dir_flags == true then
        insert_flags { str = flag_token, include_tbl = include_dir_flags, negate_tbl = negate_dir_flags, }
        goto continue
      end

      ::continue::
      flags_index = flags_index + 1
    end


    local include_flag = construct_flag { negate = false, dir_tbl = include_dir_flags, file_tbl = include_file_flags, }
    local negate_flag = construct_flag { negate = true, dir_tbl = negate_dir_flags, file_tbl = negate_file_flags, }

    local function flatten(tbl)
      return vim.iter(tbl):flatten():totable()
    end

    local cmd = flatten { conf.vimgrep_arguments, case_sensitive_flag, whole_word_flag, search, include_flag, negate_flag, }
    local minified_cmd = flatten { "rg", case_sensitive_flag, whole_word_flag, search, include_flag, negate_flag, }
    vim.notify(table.concat(minified_cmd, " "), vim.log.levels.DEBUG)
    return cmd
  end

  pickers
      .new(setup_opts, {
        default_text = opts.default_text or "~",
        prompt_title = "Live grep with custom args: -{f,d,c,nc,w,nw} ",
        finder = finders.new_job(cmd_generator, entry_maker),
        previewer = conf.grep_previewer(setup_opts),
      })
      :find()
end

-- easy debugging, reload the file
-- live_grep_with_custom_args()

return telescope.register_extension {
  exports = {
    live_grep_with_custom_args = live_grep_with_custom_args,
  },
}

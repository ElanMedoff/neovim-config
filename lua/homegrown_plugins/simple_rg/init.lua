local M = {}

--- @param input_str string
--- @return table
local function split(input_str)
  local tbl = {}
  for str in input_str:gmatch "([^%s]+)" do
    table.insert(tbl, str)
  end
  return tbl
end

--- @param tbl table
--- @return table
local function flatten(tbl)
  return vim.iter(tbl):flatten():totable()
end

--- @param opts { str: string, include_tbl: table, negate_tbl: table }
local function record_custom_flag(opts)
  local str, include_tbl, negate_tbl = opts.str, opts.include_tbl, opts.negate_tbl
  if str:sub(1, 1) == "!" then
    if #str > 1 then
      table.insert(negate_tbl, str:sub(2))
    end
  else
    table.insert(include_tbl, str)
  end
end

--- @param opts { dir_tbl: table, file_tbl: table, ext_tbl: table, negate: boolean }
local function construct_rg_flags(opts)
  local ext_tbl_processed = vim.tbl_map(function(ext)
    return "*." .. ext
  end, opts.ext_tbl)

  local dir_tbl_processed = vim.tbl_map(function(dir)
    return string.format("**/%s/**", dir)
  end, opts.dir_tbl)

  local file_ext_dir_tbl = vim.iter { opts.file_tbl, ext_tbl_processed, dir_tbl_processed, }
      :flatten()
      :totable()

  if vim.tbl_count(file_ext_dir_tbl) > 0 then
    local flag = string.format("'{%s}'", table.concat(file_ext_dir_tbl, ","))

    if opts.negate then
      flag = "!" .. flag
    end

    return "-g " .. flag
  end

  return ""
end

--- @param prompt string
local function parse_search(prompt)
  local end_tilde_index = prompt:find("~", 2)
  local end_index = end_tilde_index or (#prompt + 1)
  local search = prompt:sub(2, end_index - 1)
  return { search = ("'%s'"):format(search), search_end_index = end_index, }
end

--- @param tokens table
local function parse_flags(tokens)
  local state = nil
  local parsed = {
    include_file = {},
    negate_file = {},
    include_dir = {},
    negate_dir = {},
    include_ext = {},
    negate_ext = {},
    case_flag = { "--ignore-case", },
    word_flag = { nil, },
  }

  for _, token in ipairs(tokens) do
    if token == "-c" then
      parsed.case_flag = { "--case-sensitive", }
      state = nil
    elseif token == "-nc" then
      parsed.case_flag = { "--ignore-case", }
      state = nil
    elseif token == "-w" then
      parsed.word_flag = { "--word-regexp", }
      state = nil
    elseif token == "-nw" then
      parsed.word_flag = { nil, }
      state = nil
    elseif token == "-f" then
      state = "file"
    elseif token == "-d" then
      state = "dir"
    elseif token == "-e" then
      state = "ext"
    elseif state then
      local include_key = "include_" .. state
      local negate_key = "negate_" .. state
      record_custom_flag {
        str = token,
        include_tbl = parsed[include_key],
        negate_tbl = parsed[negate_key],
      }
    end
  end

  return parsed
end

M.construct_rg_cmd = function(prompt)
  if not prompt or prompt == "" then
    return nil
  end

  local parsed_search = parse_search(prompt)

  local flags_prompt = prompt:sub(parsed_search.search_end_index + 1)
  if flags_prompt:sub(-1) ~= " " then
    return nil
  end

  local tokens = split(flags_prompt)
  local flags = parse_flags(tokens)

  local include_flag = construct_rg_flags {
    negate = false,
    dir_tbl = flags.include_dir,
    file_tbl = flags.include_file,
    ext_tbl = flags.include_ext,
  }

  local negate_flag = construct_rg_flags {
    negate = true,
    dir_tbl = flags.negate_dir,
    file_tbl = flags.negate_file,
    ext_tbl = flags.negate_ext,
  }

  local cmd = flatten {
    "rg",
    "--line-number", "--column", "--no-heading", -- formatting for fzf-lua
    "--hidden",
    "--color=always",
    flags.case_flag, flags.word_flag,
    parsed_search.search,
    include_flag, negate_flag,
  }

  return table.concat(cmd, " ")
end

return M

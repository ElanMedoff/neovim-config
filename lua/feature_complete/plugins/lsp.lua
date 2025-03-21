local h = require "shared.helpers"
local lspconfig = require "lspconfig"

vim.opt.signcolumn = "yes" -- reserve a space in the gutter

require "mason".setup()
require "mason-lspconfig".setup {
  ensure_installed = {
    "ts_ls",
    "eslint",
    "jsonls",
    "lua_ls",
    "bashls",
    "css_variables",
    "cssls",
    "cssmodules_ls",
    "stylelint_lsp",
    "tailwindcss",
    "denols",
    "vimls",
  },
}

vim.diagnostic.config {
  virtual_text = false,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.INFO] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.HINT] = "",
    },
  },
}

local last_cursor = { nil, nil, }
vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI", }, {
  pattern = "*",
  callback = function()
    local current_cursor = vim.api.nvim_win_get_cursor(h.curr.window)

    -- when holding, don't force open the diagnostics unless the cursor has also moved
    -- allows opening another float i.e. hover
    if not (current_cursor[1] == last_cursor[1] and current_cursor[2] == last_cursor[2]) then
      vim.diagnostic.open_float { border = "single", focus = false, scope = "line", }
    end

    last_cursor = current_cursor
  end,
})

local lspconfig_defaults = lspconfig.util.default_config
lspconfig_defaults.capabilities = vim.tbl_deep_extend(
  "force",
  lspconfig_defaults.capabilities,
  require "cmp_nvim_lsp".default_capabilities()
)

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then return end

    if client.supports_method "textDocument/inlayHint" then
      vim.lsp.inlay_hint.enable(true)
    end

    if client.supports_method "textDocument/documentHighlight" then
      vim.o.updatetime = 100 -- how long until the cursor events fire
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI", }, {
        buffer = h.curr.buffer,
        callback = function()
          vim.lsp.buf.document_highlight()
        end,
      })

      vim.api.nvim_create_autocmd({ "CursorMoved", }, {
        buffer = h.curr.buffer,
        callback = function()
          vim.lsp.buf.clear_references()
        end,
      })
    end
  end,
})

h.keys.map({ "n", }, "gh", vim.lsp.buf.hover, { desc = "LSP hover", })
h.keys.map({ "n", }, "gd", vim.lsp.buf.definition, { desc = "LSP go to definition", })
h.keys.map({ "n", }, "gs", vim.lsp.buf.type_definition, { desc = "LSP go to type definition", })
h.keys.map({ "n", }, "gu", vim.lsp.buf.references, { desc = "LSP go to references", })
h.keys.map({ "n", }, "ga", vim.lsp.buf.code_action, { desc = "LSP code action", })
h.keys.map({ "n", }, "<leader>ld", function()
    local buf_diagnostics = vim.diagnostic.get(0, { severity = "ERROR", })
    vim.diagnostic.toqflist(buf_diagnostics)
    vim.cmd "copen"
  end,
  { desc = "Open LSP diagnostics with the quickfix list", })
h.keys.map({ "n", }, "gl", function()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    -- https://neovim.io/doc/user/api.html#floating-windows
    if vim.api.nvim_win_get_config(win).relative == "win" then
      local force = false
      vim.api.nvim_win_close(win, force)
    end
  end
end)

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = "single",
})

local function enable_deno_lsp()
  return h.os.file_exists(vim.fn.getcwd() .. "/.deno-enable-lsp")
end

if enable_deno_lsp() then
  lspconfig.denols.setup {}
else
  lspconfig.ts_ls.setup {
    init_options = {
      preferences = {
        importModuleSpecifierPreference = "non-relative",
        jsxAttributeCompletionStyle = "braces",
      },
    },
  }
  lspconfig.eslint.setup {}
end

lspconfig.jsonls.setup {}
lspconfig.lua_ls.setup {}
lspconfig.bashls.setup {
  settings = {
    bashIde = {
      shellcheckArguments = "--extended-analysis=false",
      shfmt = {
        simplifyCode = true,
        caseIndent = true,
      },
    },
  },
}
lspconfig.css_variables.setup {}
lspconfig.cssls.setup {}
lspconfig.cssmodules_ls.setup {}
lspconfig.stylelint_lsp.setup {}
lspconfig.tailwindcss.setup {}
lspconfig.vimls.setup {}

local cmp = require "cmp"
cmp.setup {
  sources = {
    {
      name = "nvim_lsp",
      -- https://github.com/hrsh7th/nvim-cmp/discussions/759#discussioncomment-9875581
      entry_filter = function(entry)
        return entry:get_kind() ~= cmp.lsp.CompletionItemKind.Snippet
      end,
    },
    { name = "buffer", },
    { name = "lazydev", group_index = 0, },
    { name = "path", },
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert {
    ["<C-s>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping.confirm { select = true, },
  },
}

require "lazydev".setup {}
require "nvim-autopairs".setup {}
require "conform".setup {
  formatters_by_ft = {
    css = { "prettier", },
    graphql = { "prettier", },
    html = { "prettier", },
    javascript = { "prettier", },
    javascriptreact = { "prettier", },
    json = { "prettier", },
    less = { "prettier", },
    markdown = { "prettier", },
    scss = { "prettier", },
    typescript = { "prettier", },
    typescriptreact = { "prettier", },
    yaml = { "prettier", },
  },
  format_after_save = {
    lsp_format = "fallback",
    async = true,
  },
}

local ok, null_ls = pcall(require, "null_ls")
if not ok then
  return
end

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
local formatting = null_ls.builtins.formatting

null_ls.setup({
  sources = {
    formatting.prettier,
    formatting.stylua,
  },
  -- https://github.com/jose-elias-alvarez/null-ls.nvim/wiki/Formatting-on-save#code
  on_attach = function(client, bufnr)
    if client.supports_method("textDocument/formatting") then
      vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = augroup,
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format({ bufnr = bufnr })
        end,
      })
    end
  end,
})

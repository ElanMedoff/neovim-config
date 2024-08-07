local configs = require "nvim-treesitter.configs"

configs.setup({
  ensure_installed = {
    "bash",
    "comment",
    "css",
    "html",
    "javascript",
    "json",
    "json5",
    "jsonc",
    "lua",
    "markdown",
    "regex",
    "ruby",
    "scss",
    "tsx",
    "typescript",
    "yaml",
    "vimdoc"
  },
  indent = { enable = true },
  autotag = { enable = true, },
  endwise = { enable = true, },
})

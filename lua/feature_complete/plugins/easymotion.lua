vim.api.nvim_create_autocmd({ "User" }, {
  pattern = "EasyMotionPromptBegin",
  callback = function() vim.b.coc_diagnostic_disable = 1 end
})
vim.api.nvim_create_autocmd({ "User" }, {
  pattern = "EasyMotionPromptEnd",
  callback = function() vim.b.coc_diagnostic_disable = 0 end
})

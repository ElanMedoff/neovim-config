local ok, bqf = pcall(require, "bqf")
if not ok then
  return
end

bqf.setup({
  func_map = {
    -- TODO: why doens't this work?
    --[[ openc = '<cr>', ]]
  },
})

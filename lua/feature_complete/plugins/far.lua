local h = require "shared.helpers"
local grug = require "grug-far"

-- TODO: find a cleaner way to handle this
local GRUG_INSTANCE_NAME = ""

vim.keymap.set("n", "<leader>re", function()
  if grug.has_instance(GRUG_INSTANCE_NAME) then
    grug.toggle_instance { instanceName = GRUG_INSTANCE_NAME, startInInsertMode = true, }
  else
    GRUG_INSTANCE_NAME = grug.open()
  end
  vim.cmd "vertical resize 135%"
  h.notify.info "Common flags: --case-sensitive (default), --ignore-case, --word-regexp"
end, { desc = "Open the grug-far ui", })

grug.setup {
  keymaps = {
    replace = false,
    qflist = { n = "<leader>rq", },
    syncLocations = { n = "<leader>rs", },
    syncLine = { n = "<leader>rl", },
    close = { n = "<leader>q", },
    historyOpen = { n = "<leader>rh", },
    historyAdd = false,
    refresh = { n = "<leader>e", },
    openLocation = { n = "<leader>ro", },
    openNextLocation = { n = "<C-j>", },
    openPrevLocation = { n = "<C-k>", },
    gotoLocation = { n = "<enter>", },
    pickHistoryEntry = { n = "<enter>", },
    abort = false,
    help = { n = "g?", },
    toggleShowCommand = false,
    swapEngine = false,
    previewLocation = { n = "<leader>rp", },
    swapReplacementInterpreter = false,
  },
}

vim.api.nvim_create_autocmd({ "FileType", }, {
  pattern = "grug-far",
  callback = function()
    vim.keymap.set("i", "<C-c>", "<Esc><leader>q", { buffer = h.curr.buffer, })
  end,
})

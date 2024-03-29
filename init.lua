local h = require "shared.helpers"

-- remap leader before importing remaps that use it
h.map("", "<space>", "<nop>")
h.let.mapleader = " "

-- for bootstrapping
local packer_status_ok = pcall(require, "packer")
if not packer_status_ok then
  require "settings.plugins.packer"
  return
end

require "settings.plugins"
require "settings.functions"
require "settings.remaps"

require "settings.options"

require "shared.options"
require "shared.remaps"

-- TODO:
-- 1. List of errors to ignore, like that a buffer doesn't exist anymore, or that a git job timed out
-- 2. spell checker

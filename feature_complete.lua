local h = require "shared.helpers"

-- remap leader before importing remaps that use it
h.keys.map({ "", }, "<space>", "<nop>")
h.let.mapleader = " "
h.let.maplocalleader = " "

require "shared.options"
require "shared.remaps"
require "shared.user_commands"
require "feature_complete"

-- TODO:
-- merge conflicts with fugitive
-- diff for current file over several commits

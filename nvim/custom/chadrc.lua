---@type ChadrcConfig
local M = {}

M.mappings = require("custom.mappings")
M.plugins = "custom.plugins"
local highlights = require("custom.highlights")

M.ui = { theme = "palenight", hl_override = highlights.override, hl_add = highlights.add }
return M

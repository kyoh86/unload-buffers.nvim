--- Get a value from parameter table.
---@param params unload.Params
---@param key string @A name of the parameter.
---@param default any @A default value.
---@return any
local function get_param(params, key, default)
    if params == nil or type(params) ~= "table" or vim.tbl_islist(params) then
        return default
    elseif not vim.fn.has_key(params, key) then
        return default
    end
    return params[key]
end

--- Normalize a parameter table.
---@param params unload.OptionalParams?
---@return unload.Params
local function normalize_params(params)
    return {
        force = get_param(params, "force", false),
        keep_layout = get_param(params, "keep_layout", false),
        filter = get_param(params, "filter", nil),
        debug = get_param(params, "debug", false),
    }
end

local M = {}

local static = require("unload.static")
local active = require("unload.active")

--- Wipe buffers other of the one in the current window.
---@param params unload.OptionalParams?
function M.other(params)
    static.other(normalize_params(params))
end

--- Wipe buffers loaded but currently not displayed in any window.
---@param params unload.OptionalParams?
function M.hidden(params)
    static.hidden(normalize_params(params))
end

--- Wipe buffers having no name.
---@param params unload.OptionalParams?
function M.nameless(params)
    static.nameless(normalize_params(params))
end

--- Wipe all buffers.
---@param params unload.OptionalParams?
function M.all(params)
    static.all(normalize_params(params))
end

--- Wipe a buffer in the current window.
---@param params unload.OptionalParams?
function M.current(params)
    static.current(normalize_params(params))
end

--- Open a menu to choose one of behaviors below.
---@param params unload.OptionalParams?
function M.menu(params)
    active.menu(normalize_params(params))
end

--- Lets you interactively select which buffers to wipe.
---@param params unload.OptionalParams?
function M.select(params)
    active.select(normalize_params(params))
end

return M

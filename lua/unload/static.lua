local buffer = require("unload.buffer")
local core = require("unload.core")

local M = {}

--- Wipe buffers other of the one in the current window.
---@param params unload.Params
function M.other(params)
    local current = buffer.current_number()
    core.filtered(params, {
        function(item)
            return item.bufnr ~= current
        end,
    })
end

--- Wipe buffers loaded but currently not displayed in any window.
---@param params unload.Params
function M.hidden(params)
    core.filtered(params, {
        function(item)
            return #item.windows == 0
        end,
    })
end

--- Wipe buffers having no name.
---@param params unload.Params
function M.nameless(params)
    core.filtered(params, {
        function(item)
            return item.name == ""
        end,
    })
end

--- Wipe all buffers.
---@param params unload.Params
function M.all(params)
    core.filtered(params)
end

--- Wipe a buffer in the current window.
---@param params unload.Params
function M.current(params)
    core.one(params, buffer.current())
end

return M

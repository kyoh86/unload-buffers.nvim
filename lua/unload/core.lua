local buffer = require("unload.buffer")

---@alias unload.BufInfo {bufnr: number, changed: boolean, changedtick: number, hidden: boolean, lastused: number, listed: boolean, lnum: number,linecount: number, loaded: boolean, name: string, variables: table, windows: number[]}
---@see getbufinfo()

---@alias unload.Filter fun(unload.BufInfo): boolean
---@alias unload.Params {force: boolean, keep_layout: boolean, filter: unload.Filter, debug: boolean}
---@alias unload.OptionalParams {force: boolean?, keep_layout: boolean?, filter: unload.Filter?, debug: boolean?}

local M = {}

--- Set buffer to windows.
---@param windows window[]
---@param bufnr buffer
local function wins_set_buf(windows, bufnr)
  for _, window in pairs(windows) do
    if bufnr < 0 then
      bufnr = vim.api.nvim_create_buf(true, false)
    end
    vim.api.nvim_win_set_buf(window, bufnr)
  end
end

--- Get alternative buffer for the bufinfo
---@param bufinfo unload.BufInfo
---@return buffer
local function get_alt_buffer(bufinfo)
  local candidate, found = -1, false
  for _, bi in ipairs(buffer.all()) do
    if bi.bufnr == bufinfo.bufnr then
      found = true
    elseif bi.listed ~= 0 and vim.tbl_isempty(bi.windows) then
      if found then
        return bi.bufnr
      elseif candidate < 0 then
        candidate = bi.bufnr
      end
    end
  end
  return candidate
end

--- Unload buffers matched for filters.
---@param params unload.Params
---@param filters unload.Filter[]?
function M.filtered(params, filters)
  local filter = buffer.build_filter(params, filters)
  local dels, rews, alter = {}, {}, -1
  for _, bi in ipairs(vim.fn.reverse(buffer.all())) do
    if filter(bi) then
      -- prepare to delete buffer
      if params.keep_layout then
        if alter < 0 then
          rews = vim.list_extend(rews, bi.windows)
        else
          wins_set_buf(bi.windows, alter)
        end
      end
      table.insert(dels, bi.bufnr)
    elseif bi.listed ~= 0 and vim.tbl_isempty(bi.windows) then
      alter = bi.bufnr
    end
  end
  wins_set_buf(rews, alter)
  if not vim.tbl_isempty(dels) then
    local bang = ""
    if params.force then
      bang = "!"
    end
    vim.cmd("silent bunload" .. bang .. " " .. vim.fn.join(dels, " "))
  end
end

--- Unload one buffer
---@param params unload.Params
---@param bufinfo unload.BufInfo
function M.one(params, bufinfo)
  if params.keep_layout then
    wins_set_buf(bufinfo.windows, get_alt_buffer(bufinfo))
  end
  vim.api.nvim_buf_delete(bufinfo.bufnr, { force = params.force })
end

return M

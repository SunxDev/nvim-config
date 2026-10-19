-- On-demand popup listing the cursor line's diagnostics (keys in lua/config/keymaps.lua).
-- It is pinned inside the current window, right under the cursor line, and closes when
-- the cursor moves or on <Esc>; look/format lives in `diagnostics.float`
-- (lua/plugins/lsp.lua).

local MIN_WIDTH = 40

local M = {}
local popup ---@type integer?

--- Opens the popup for the cursor line, if it has diagnostics.
function M.open()
  local win = vim.api.nvim_get_current_win()
  local info = vim.fn.getwininfo(win)[1]
  local _, float = vim.diagnostic.open_float({
    scope = "line",
    focusable = false,
    -- keep the popup no wider than the window it describes (minus the border)
    max_width = math.max(info.width - info.textoff - 2, MIN_WIDTH),
    -- not WinScrolled: it also fires when the float itself appears, closing it at once
    close_events = { "CursorMoved", "InsertEnter", "BufLeave", "WinLeave" },
  })
  if not float then
    return
  end
  -- open_float also records itself as vim.b.lsp_floating_preview, the same marker
  -- hover uses; tag it so the hover keymaps (lua/config/keymaps.lua) leave it alone.
  vim.w[float].diagnostic_popup = true
  popup = float

  -- Pin it to this window's text column, right under the whole (possibly wrapped)
  -- cursor line, instead of following the cursor column into neighbouring windows.
  local lnum = vim.api.nvim_win_get_cursor(win)[1]
  local line_len = math.max(#vim.fn.getline(lnum), 1)
  local first_row = vim.fn.screenpos(win, lnum, 1).row - info.winrow
  local last_row = vim.fn.screenpos(win, lnum, line_len).row - info.winrow
  local height = vim.api.nvim_win_get_height(float) + 2 -- border
  local row = last_row + 1
  if row + height > info.height and first_row - height >= 0 then
    row = first_row - height
  end
  -- anchor must be reset: near the right edge the preview opens anchored "NE"
  vim.api.nvim_win_set_config(float, {
    relative = "editor",
    anchor = "NW",
    row = info.winrow - 1 + row,
    col = info.wincol - 1 + info.textoff,
  })
end

--- Closes the popup if it's open.
---@return boolean closed
function M.dismiss()
  if not (popup and vim.api.nvim_win_is_valid(popup)) then
    return false
  end
  vim.api.nvim_win_close(popup, true)
  popup = nil
  return true
end

return M

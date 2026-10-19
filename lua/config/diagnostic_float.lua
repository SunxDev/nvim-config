-- Pop up the cursor line's diagnostics in a float once the cursor rests there
-- (`CursorHold`, i.e. after 'updatetime'). The float closes as soon as the cursor
-- moves, so the code never shifts; look/format lives in `diagnostics.float`
-- (lua/plugins/lsp.lua).

local group = vim.api.nvim_create_augroup("diagnostic_float", { clear = true })
local MIN_WIDTH = 40

local M = {}
local popup ---@type integer?
--- Line whose popup was dismissed with <Esc>; it stays closed until the cursor leaves it.
local dismissed ---@type { buf: integer, lnum: integer }?

--- Another popup is anchored at the cursor (LSP hover, signature help). Notifications
--- are editor-relative and the snacks explorer sidebar is window-relative, so neither
--- blocks the diagnostics popup.
local function cursor_popup_open()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_get_config(win).relative == "cursor" then
      return true
    end
  end
  return false
end

vim.api.nvim_create_autocmd("CursorHold", {
  group = group,
  callback = function()
    if vim.api.nvim_get_mode().mode ~= "n" or cursor_popup_open() then
      return
    end
    local win = vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_get_current_buf()
    local lnum = vim.api.nvim_win_get_cursor(win)[1]
    if dismissed and dismissed.buf == buf and dismissed.lnum == lnum then
      return
    end
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
  end,
})

vim.api.nvim_create_autocmd("CursorMoved", {
  group = group,
  callback = function()
    if dismissed and (dismissed.buf ~= vim.api.nvim_get_current_buf() or dismissed.lnum ~= vim.fn.line(".")) then
      dismissed = nil
    end
  end,
})

--- Closes the popup if it's open and keeps it closed for the current line.
---@return boolean closed
function M.dismiss()
  if not (popup and vim.api.nvim_win_is_valid(popup)) then
    return false
  end
  vim.api.nvim_win_close(popup, true)
  popup = nil
  dismissed = { buf = vim.api.nvim_get_current_buf(), lnum = vim.fn.line(".") }
  return true
end

return M

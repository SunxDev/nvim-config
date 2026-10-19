-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- While a hover (K, native float) / noice signature popup is open: j/k scroll it, <Esc>
-- closes it. Otherwise they keep LazyVim's behaviour (gj/gk without a count; Esc clears hlsearch).
---@return integer? win, fun()? close
local function lsp_doc()
  -- Native hover (lua/plugins/hover.lua): Neovim records the float on the source buffer.
  -- The diagnostics popup sets the same buffer var; it's not a hover, so skip it.
  local hover = vim.b.lsp_floating_preview
  if hover and vim.api.nvim_win_is_valid(hover) and not vim.w[hover].diagnostic_popup then
    return hover, function()
      vim.api.nvim_win_close(hover, true)
    end
  end
  -- noice keeps the shown docs per kind; its public getter clears them, so read directly
  local docs = require("noice.lsp.docs")
  local message = docs._messages.signature
  local win = message and message:win()
  if win then
    return win, function()
      docs.hide(message)
    end
  end
end

--- Last line that actually shows something. LSP hover markdown often ends with a blank
--- line plus a closing ``` fence (concealed by render-markdown); scrolling to reveal
--- those only exposes empty space.
---@param buf integer
local function last_content_line(buf)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  for i = #lines, 1, -1 do
    local line = vim.trim(lines[i])
    if line ~= "" and not line:match("^```") then
      return i
    end
  end
  return 1
end

--- True while content below the window's last row is still hidden.
---@param win integer
local function has_more_below(win)
  local view = vim.api.nvim_win_call(win, vim.fn.winsaveview)
  local last = last_content_line(vim.api.nvim_win_get_buf(win))
  if last < view.topline then
    return false
  end
  local rows = vim.api.nvim_win_text_height(win, {
    start_row = view.topline - 1,
    start_vcol = view.skipcol,
    end_row = last - 1,
  })
  return rows.all > vim.api.nvim_win_get_height(win)
end

-- Plain (non-expr) mappings: scrolling right away keeps held-down j/k from collapsing
-- into one step, which noice's deferred scroll does. Scrolling down stops once the last
-- line is visible; <C-y> already stops at the top on its own.
for key, scroll in pairs({ j = "\5", k = "\25" }) do -- <C-e> / <C-y>
  vim.keymap.set("n", key, function()
    local count = vim.v.count
    local win = lsp_doc()
    if win then
      vim.api.nvim_win_call(win, function()
        for _ = 1, math.max(count, 1) do
          if key == "j" and not has_more_below(win) then
            return
          end
          vim.cmd("normal! " .. scroll)
        end
      end)
      return
    end
    vim.api.nvim_feedkeys(count == 0 and ("g" .. key) or (count .. key), "n", false)
  end, { silent = true, desc = key == "j" and "Down / Scroll Hover" or "Up / Scroll Hover" })
end

vim.keymap.set("n", "<esc>", function()
  local _, close = lsp_doc()
  if close then
    close()
    return
  end
  if require("config.diagnostic_float").dismiss() then
    return
  end
  vim.cmd("noh")
  LazyVim.cmp.actions.snippet_stop()
end, { desc = "Close Hover or Diagnostics Popup / Escape and Clear hlsearch" })

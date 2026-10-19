-- Built-in `quiet` (dark via vim.o.background in options.lua), plus dark grays for the
-- UI chrome it leaves light (floats, statusline, tabline), typographic syntax
-- distinctions, and colored git add/change/delete markers.
local c = {
  bg = "#000000",
  bg1 = "#121212",
  bg2 = "#1c1c1c",
  bg3 = "#303030",
  gray = "#707070",
  fg = "#dadada",
  white = "#ffffff",
  accent = "#ffaf00", -- quiet's own Visual/IncSearch color
  red = "#d75f5f",
  green = "#00af00", -- quiet's DiffAdd/DiffChange/DiffDelete colors
  blue = "#87afd7",
  -- code brightness tiers (bold alone is too subtle at small font sizes)
  code = "#bcbcbc", -- plain text, variables
  string = "#949494",
  func = "#e4e4e4",
}

local function apply()
  local hl = function(name, val) vim.api.nvim_set_hl(0, name, val) end
  -- floats: blink.cmp, mini.files, trouble, dap-ui, noice, snacks link to these
  hl("NormalFloat", { fg = c.fg, bg = c.bg2 })
  hl("FloatBorder", { fg = c.gray, bg = c.bg2 })
  hl("FloatTitle", { fg = c.white, bg = c.bg2, bold = true })
  hl("Pmenu", { fg = c.fg, bg = c.bg2 })
  hl("PmenuSel", { fg = c.white, bg = c.bg3, bold = true })
  hl("PmenuKind", { fg = c.gray, bg = c.bg2 })
  hl("PmenuKindSel", { fg = c.fg, bg = c.bg3 })
  hl("PmenuExtra", { fg = c.gray, bg = c.bg2 })
  hl("PmenuExtraSel", { fg = c.fg, bg = c.bg3 })
  hl("PmenuMatch", { fg = c.white, bg = c.bg2, bold = true })
  hl("PmenuMatchSel", { fg = c.white, bg = c.bg3, bold = true })
  hl("PmenuSbar", { bg = c.bg2 })
  hl("PmenuThumb", { bg = c.bg3 })
  hl("PmenuBorder", { link = "FloatBorder" })
  hl("MessageWindow", { link = "NormalFloat" })
  -- bars and separators
  hl("StatusLine", { fg = c.fg, bg = c.bg2 })
  hl("StatusLineNC", { fg = c.gray, bg = c.bg1 })
  hl("StatusLineTerm", { link = "StatusLine" })
  hl("StatusLineTermNC", { link = "StatusLineNC" })
  hl("TabLine", { fg = c.gray, bg = c.bg1 })
  hl("TabLineFill", { bg = c.bg })
  hl("TabLineSel", { fg = c.white, bg = c.bg3, bold = true })
  hl("WinSeparator", { fg = c.bg3 })
  hl("MsgSeparator", { fg = c.bg3 })
  hl("TreesitterContext", { bg = c.bg1 })
  hl("TreesitterContextBottom", { underline = true, sp = c.bg3 })
  -- syntax: quiet is one color; tell things apart by brightness first, then weight/slant
  hl("Normal", { fg = c.code, bg = c.bg })
  hl("Comment", { fg = c.gray, italic = true })
  hl("Statement", { fg = c.white, bold = true }) -- Keyword, Conditional, Repeat, @keyword link here
  hl("Function", { fg = c.func })
  hl("Type", { fg = c.code, italic = true })
  -- quiet links builtin types (u32, bool, str) to Special, which is upright; keep its color, add italic
  hl("@type.builtin", { fg = c.fg, italic = true })
  hl("String", { fg = c.string })
  hl("Constant", { fg = c.code, bold = true }) -- numbers, booleans, nil
  hl("@variable.builtin", { fg = c.code, italic = true }) -- self, this
  -- inlay hints (`: String`, param names): dim text on a faint chip so they never read as code
  hl("LspInlayHint", { fg = c.gray, bg = c.bg2, italic = true })
  -- git markers: gitsigns and lualine's diff component read these
  hl("Added", { fg = c.green })
  hl("Changed", { fg = c.blue })
  hl("Removed", { fg = c.red })
end

local lualine_theme = {
  normal = { a = { fg = c.bg, bg = c.fg, gui = "bold" }, b = { fg = c.fg, bg = c.bg3 }, c = { fg = c.fg, bg = c.bg2 } },
  insert = { a = { fg = c.bg, bg = c.white, gui = "bold" } },
  visual = { a = { fg = c.bg, bg = c.accent, gui = "bold" } },
  replace = { a = { fg = c.bg, bg = c.red, gui = "bold" } },
  command = { a = { fg = c.bg, bg = c.gray, gui = "bold" } },
  inactive = { a = { fg = c.gray, bg = c.bg1 }, b = { fg = c.gray, bg = c.bg1 }, c = { fg = c.gray, bg = c.bg1 } },
}

vim.api.nvim_create_autocmd("ColorScheme", { pattern = "quiet", callback = apply })

return {
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "quiet" },
  },
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.options = opts.options or {}
      opts.options.theme = lualine_theme
      -- explicit colors: lualine otherwise snapshots them once from highlight groups at startup
      for _, comp in ipairs(opts.sections and opts.sections.lualine_x or {}) do
        if type(comp) == "table" and comp[1] == "diff" then
          comp.diff_color = { added = { fg = c.green }, modified = { fg = c.blue }, removed = { fg = c.red } }
        end
      end
    end,
  },
}

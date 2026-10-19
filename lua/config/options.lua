-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Set explicitly so Neovim's terminal background detection can't flip quiet to light.
vim.o.background = "dark"

-- Soft wrap long lines (LazyVim defaults to nowrap); toggle per buffer with <leader>uw.
vim.o.wrap = true
vim.o.linebreak = true -- break at word boundaries, not mid-word
vim.o.breakindent = true -- wrapped lines keep the line's indentation

-- Mouse off (LazyVim defaults to "a"): clicks/scroll no longer move the cursor;
-- selecting/copying with the mouse is handled by the terminal instead.
vim.o.mouse = ""

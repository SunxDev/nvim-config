-- K uses Neovim's native hover instead of noice's: the native float keeps the raw markdown
-- (`####` headings, ``` fences) with filetype=markdown, so render-markdown.nvim renders it.
-- noice's hover strips the fences and only syntax-highlights, which leaves `####` visible.
-- Signature help lives in lsp-signature.lua (lsp_signature.nvim).
return {
  {
    "folke/noice.nvim",
    opts = {
      lsp = {
        hover = { enabled = false },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- Appended, so it replaces LazyVim's `K` (same lhs, last one wins).
      table.insert(opts.servers["*"].keys, {
        "K",
        function()
          return vim.lsp.buf.hover({ border = "rounded", max_width = 100, max_height = 25 })
        end,
        desc = "Hover",
      })
    end,
  },
}

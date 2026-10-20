-- Signature help while typing: floating signature + 🐼 hint for the active parameter.
-- noice's signature help is disabled so the two floats don't stack.
return {
  {
    "folke/noice.nvim",
    opts = {
      lsp = {
        signature = { enabled = false },
      },
    },
  },
  {
    "ray-x/lsp_signature.nvim",
    event = "LspAttach",
    opts = {
      bind = true,
      hint_enable = true,
      hint_prefix = "🐼 ",
      floating_window = true,
      handler_opts = { border = "rounded" },
    },
  },
}

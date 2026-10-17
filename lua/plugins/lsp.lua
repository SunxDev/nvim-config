return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      diagnostics = {
        -- Other lines: short inline text. Cursor line: full message on lines below (nvim >= 0.11).
        virtual_text = { current_line = false },
        virtual_lines = { current_line = true },
      },
      servers = {
        -- nil comes from nixpkgs (modules/packages.nix); Mason would need cargo.
        nil_ls = { mason = false },
      },
    },
  },
}

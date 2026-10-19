local SEVERITY_HL = {
  [vim.diagnostic.severity.ERROR] = "DiagnosticFloatingError",
  [vim.diagnostic.severity.WARN] = "DiagnosticFloatingWarn",
  [vim.diagnostic.severity.INFO] = "DiagnosticFloatingInfo",
  [vim.diagnostic.severity.HINT] = "DiagnosticFloatingHint",
}

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      diagnostics = {
        -- Other lines: short inline text. Cursor line: full list in a popup once the
        -- cursor rests there (lua/config/diagnostic_float.lua), or <leader>cd.
        virtual_text = { current_line = false },
        virtual_lines = false,
        float = {
          border = "rounded",
          header = "",
          source = false, -- shown in the suffix next to the code instead
          prefix = function(diagnostic)
            local signs = vim.diagnostic.config().signs
            local icon = type(signs) == "table" and signs.text and signs.text[diagnostic.severity] or "●"
            return vim.trim(icon) .. " ", SEVERITY_HL[diagnostic.severity]
          end,
          suffix = function(diagnostic)
            local origin = table.concat(
              vim.tbl_filter(function(part)
                return part ~= nil and part ~= ""
              end, { diagnostic.source, diagnostic.code and tostring(diagnostic.code) }),
              " "
            )
            return origin == "" and "" or ("  " .. origin), "Comment"
          end,
        },
      },
      servers = {
        -- nil comes from nixpkgs (modules/packages.nix); Mason would need cargo.
        nil_ls = { mason = false },
      },
    },
  },
}

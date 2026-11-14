return {
  'stevearc/conform.nvim',
  opts = {
    notify_on_error = false,
    format_on_save = function(bufnr)
      local disable_filetypes = {}
      return {
        timeout_ms = 500,
        lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
      }
    end,
    -- biome is guarded by a condition so it only runs in projects that have a
    -- biome config file. Without this guard, biome is always found (it lives in
    -- mason's bin) and stop_after_first would never reach prettierd/prettier.
    formatters = {
      biome = {
        condition = function(_, ctx)
          return vim.fs.root(ctx.buf, { 'biome.json', 'biome.jsonc' }) ~= nil
        end,
      },
    },
    formatters_by_ft = {
      lua = { 'stylua' },
      javascript = { 'biome', 'prettierd', 'prettier', stop_after_first = true },
      javascriptreact = { 'biome', 'prettierd', 'prettier', stop_after_first = true },
      typescript = { 'biome', 'prettierd', 'prettier', stop_after_first = true },
      typescriptreact = { 'biome', 'prettierd', 'prettier', stop_after_first = true },
      c = { 'clang-format' },
    },
  },
}

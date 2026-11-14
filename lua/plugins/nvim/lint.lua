return {
  'mfussenegger/nvim-lint',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    local ok, lint = pcall(require, 'lint')
    if not ok then
      return
    end

    lint.linters_by_ft = {
      javascript = { 'biomejs' },
      javascriptreact = { 'biomejs' },
      typescript = { 'biomejs' },
      typescriptreact = { 'biomejs' },
    }

    local lint_augroup = vim.api.nvim_create_augroup('nvim-lint', { clear = true })
    vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
      group = lint_augroup,
      callback = function()
        lint.try_lint()
      end,
    })
  end,
}

-- nvim-treesitter (main branch). On main the plugin is only a parser/query
-- installer; highlighting, indentation and folds are wired to Neovim's
-- built-in treesitter APIs via the FileType autocmd below.
-- Requires: tree-sitter CLI (installed via mason, see lsp.lua), a C compiler, curl, tar.
local ensure_installed = {
  'bash',
  'c',
  'html',
  'lua',
  'markdown',
  'markdown_inline',
  'vim',
  'vimdoc',
  'javascript',
  'typescript',
  'tsx',
  'wgsl',
}

return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  lazy = false,
  build = ':TSUpdate',
  config = function()
    -- The tree-sitter CLI is installed by mason (see lsp.lua). Make sure it is
    -- on PATH here too, since this plugin may load before the LSP spec does.
    local mason_bin = vim.fn.stdpath 'data' .. '/mason/bin'
    if not vim.env.PATH:find(mason_bin, 1, true) then
      vim.env.PATH = mason_bin .. ':' .. vim.env.PATH
    end

    local ts = require 'nvim-treesitter'
    ts.setup {}

    -- Install any missing parsers asynchronously; no-op when already present.
    local installed = ts.get_installed 'parsers'
    local missing = vim.tbl_filter(function(lang)
      return not vim.tbl_contains(installed, lang)
    end, ensure_installed)
    if #missing > 0 then
      ts.install(missing)
    end

    -- Start treesitter highlighting/indent for every buffer whose filetype has
    -- an installed parser. Filetype -> language mapping handles cases like
    -- 'typescriptreact' -> 'tsx'.
    vim.api.nvim_create_autocmd('FileType', {
      group = vim.api.nvim_create_augroup('kickstart-treesitter-start', { clear = true }),
      callback = function(event)
        local lang = vim.treesitter.language.get_lang(event.match)
        if not lang or not vim.tbl_contains(ts.get_installed 'parsers', lang) then
          return
        end
        local ok = pcall(vim.treesitter.start, event.buf, lang)
        if ok then
          vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })
  end,
}

return {
  'neovim/nvim-lspconfig',
  dependencies = {
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    { 'j-hui/fidget.nvim', opts = {} },
    -- lazydev replaces the deprecated neodev.nvim; provides Neovim API
    -- completions and type hints for lua_ls without patching LSP internals.
    {
      'folke/lazydev.nvim',
      ft = 'lua',
      opts = {
        library = {
          { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
        },
      },
    },
    'hrsh7th/cmp-nvim-lsp',
  },
  config = function()
    -- LspAttach: keymaps + document highlight wiring.
    -- The highlight augroup uses clear=false so multiple clients on the same
    -- buffer each register their own callbacks, and LspDetach removes only
    -- that buffer's entries when a client leaves.
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
      callback = function(event)
        local map = function(keys, func, desc)
          vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
        map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
        map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
        map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
        map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
        map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
        map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
        map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
        map('K', vim.lsp.buf.hover, 'Hover Documentation')
        map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client.server_capabilities.documentHighlightProvider then
          local hl_group = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = event.buf,
            group = hl_group,
            callback = vim.lsp.buf.document_highlight,
          })
          vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = event.buf,
            group = hl_group,
            callback = vim.lsp.buf.clear_references,
          })
          -- Clean up when this specific client detaches from the buffer.
          vim.api.nvim_create_autocmd('LspDetach', {
            buffer = event.buf,
            group = hl_group,
            once = true,
            callback = function()
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds { group = hl_group, buffer = event.buf }
            end,
          })
        end
      end,
    })

    -- Broadcast nvim-cmp capabilities to every server.
    -- vim.lsp.config('*') merges with per-server runtime configs (lsp/<name>.lua)
    -- so this is safe to call before servers are individually configured.
    local capabilities = vim.tbl_deep_extend(
      'force',
      vim.lsp.protocol.make_client_capabilities(),
      require('cmp_nvim_lsp').default_capabilities()
    )
    vim.lsp.config('*', { capabilities = capabilities })

    -- Per-server settings. To add a new LSP: drop an entry here.
    -- mason-lspconfig will ensure it is installed; vim.lsp.enable will start it.
    local servers = {
      ts_ls = {},
      -- WGSL (WebGPU Shading Language). Binary is installed by mason as
      -- 'wgsl-analyzer'; lspconfig ships the default cmd/filetypes.
      wgsl_analyzer = {},
      lua_ls = {
        settings = {
          Lua = {
            completion = { callSnippet = 'Replace' },
          },
        },
      },
    }

    for name, config in pairs(servers) do
      if next(config) then
        vim.lsp.config(name, config)
      end
    end

    require('mason').setup()

    -- Make mason-installed binaries available to the FileType autocommands that
    -- vim.lsp.enable creates. Without this the cmd lookup fails and servers
    -- never start.
    local mason_bin = vim.fn.stdpath 'data' .. '/mason/bin'
    if not vim.env.PATH:find(mason_bin, 1, true) then
      vim.env.PATH = mason_bin .. ':' .. vim.env.PATH
    end

    -- ensure_installed keeps the listed servers up to date via mason.
    -- automatic_enable=false avoids the async registry.refresh race that can
    -- fire after the first buffer's FileType event has already passed.
    require('mason-lspconfig').setup {
      ensure_installed = vim.tbl_keys(servers),
      automatic_enable = false,
    }

    -- tree-sitter-cli is required by nvim-treesitter (main branch) to build
    -- parsers; installing it via mason keeps it off the system package manager.
    require('mason-tool-installer').setup {
      ensure_installed = { 'stylua', 'biome', 'prettierd', 'tree-sitter-cli' },
    }

    -- Enable exactly the servers in the table above. get_installed_servers()
    -- also returns formatters/linters (biome, stylua) that have lspconfig
    -- entries but should not run as LSP servers — enabling everything installed
    -- is too broad and causes spurious diagnostics.
    vim.lsp.enable(vim.tbl_keys(servers))
  end,
}

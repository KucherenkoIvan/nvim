vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true

require 'config.nvim.options'
require 'config.nvim.keymaps'
require 'config.nvim.autocmds'
require 'config.nvim.lazy'

vim.filetype.add { extension = { templ = 'templ' } }

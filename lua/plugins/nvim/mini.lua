return {
  'echasnovski/mini.nvim',
  config = function()
    require('mini.ai').setup { n_lines = 500 }
    require('mini.surround').setup {
      custom_surroundings = {
        ['('] = { output = { left = '(', right = ')' } },
        ['['] = { output = { left = '[', right = ']' } },
        ['{'] = { output = { left = '{', right = '}' } },
        ['<'] = { output = { left = '<', right = '>' } },
      },
    }

    local statusline = require 'mini.statusline'
    statusline.setup { use_icons = vim.g.have_nerd_font }

    statusline.section_location = function()
      return '%2l:%-2v'
    end
  end,
}

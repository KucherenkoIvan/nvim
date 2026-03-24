return {
  'folke/which-key.nvim',
  event = 'VimEnter',
  opts = {
    delay = function()
      return 2500
    end,
  },
  config = function()
    require('which-key').setup()
  end,
}

return {
  'folke/which-key.nvim',
  event = 'VimEnter',
  opts = {
    delay = function()
      return 1250
    end,
  },
}

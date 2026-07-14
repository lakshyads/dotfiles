return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    build = ':TSUpdate',
    lazy = false,
    priority = 1000,
    config = function()
      require('nvim-treesitter').install({
        'markdown', 'markdown_inline',
        'lua', 'vim', 'vimdoc', 'query',
        'bash', 'json', 'yaml', 'toml',
        'python', 'javascript', 'typescript', 'tsx',
        'html', 'css',
        'go', 'java', 'c', 'cpp', 'rust', 'sql',
      })
      -- main branch dropped the old highlight.enable config; this is the
      -- documented replacement for auto-starting highlighting per buffer
      vim.api.nvim_create_autocmd('FileType', {
        callback = function(args)
          local lang = vim.treesitter.language.get_lang(args.match) or args.match
          if vim.treesitter.language.add(lang) then
            vim.treesitter.start(args.buf, lang)
          end
        end,
      })
    end,
  },
}

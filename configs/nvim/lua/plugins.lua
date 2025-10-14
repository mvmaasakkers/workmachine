-- Plugin configuration using lazy.nvim

return require("lazy").setup({
  -- File explorer
  {
    "preservim/nerdtree",
    lazy = false,
  },

  -- Status line
  {
    "vim-airline/vim-airline",
    lazy = false,
    dependencies = {
      "vim-airline/vim-airline-themes",
    },
  },

  -- Git integration
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G" },
  },

  -- Fuzzy finder
  {
    "junegunn/fzf",
    build = function()
      vim.fn["fzf#install"]()
    end,
    lazy = false,
  },
  {
    "junegunn/fzf.vim",
    lazy = false,
    dependencies = { "junegunn/fzf" },
  },

  -- Auto pairs
  {
    "jiangmiao/auto-pairs",
    event = "InsertEnter",
  },

  -- Color scheme
  {
    "morhetz/gruvbox",
    lazy = false,
    priority = 1000,
    config = function()
      vim.opt.background = "dark"
      vim.cmd([[colorscheme gruvbox]])
    end,
  },

  -- Language support
  {
    "sheerun/vim-polyglot",
    lazy = false,
  },
})

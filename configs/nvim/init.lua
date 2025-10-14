-- Neovim Configuration with lazy.nvim

-- Bootstrap lazy.nvim
require("lazy-bootstrap")

-- General settings
vim.opt.number = true              -- Show line numbers
vim.opt.relativenumber = true      -- Relative line numbers
vim.opt.expandtab = true           -- Use spaces instead of tabs
vim.opt.tabstop = 4                -- Tab width
vim.opt.shiftwidth = 4             -- Indent width
vim.opt.smartindent = true         -- Auto indent
vim.opt.wrap = true                -- Wrap lines
vim.opt.ignorecase = true          -- Case insensitive search
vim.opt.smartcase = true           -- Case sensitive when uppercase present
vim.opt.incsearch = true           -- Incremental search
vim.opt.hlsearch = true            -- Highlight search results
vim.opt.termguicolors = true       -- True color support
vim.opt.clipboard = "unnamedplus"  -- System clipboard
vim.opt.mouse = "a"                -- Enable mouse
vim.opt.updatetime = 300           -- Faster completion
vim.opt.timeoutlen = 500           -- Faster key sequence completion

-- Set leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Key mappings
local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- NERDTree mappings
keymap("n", "<leader>n", ":NERDTreeToggle<CR>", opts)
keymap("n", "<leader>f", ":NERDTreeFind<CR>", opts)

-- FZF mappings
keymap("n", "<leader>p", ":Files<CR>", opts)
keymap("n", "<leader>b", ":Buffers<CR>", opts)
keymap("n", "<leader>g", ":Rg<CR>", opts)

-- Window navigation
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

-- Clear search highlight
keymap("n", "<leader>/", ":nohlsearch<CR>", opts)

-- Save and quit
keymap("n", "<leader>w", ":w<CR>", opts)
keymap("n", "<leader>q", ":q<CR>", opts)

-- Auto-save on focus lost
vim.api.nvim_create_autocmd("FocusLost", {
  pattern = "*",
  command = "silent! wa"
})

-- Remove trailing whitespace on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  command = [[%s/\s\+$//e]]
})

-- Load plugins
require("plugins")

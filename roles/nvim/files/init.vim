" Basic Neovim Configuration

" Install vim-plug if not found
if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif

" Plugins
call plug#begin('~/.local/share/nvim/plugged')

" File explorer
Plug 'preservim/nerdtree'

" Status line
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Git integration
Plug 'tpope/vim-fugitive'

" Fuzzy finder
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Auto pairs
Plug 'jiangmiao/auto-pairs'

" Color scheme
Plug 'morhetz/gruvbox'

" Language support
Plug 'sheerun/vim-polyglot'

call plug#end()

" General settings
set number              " Show line numbers
set relativenumber      " Relative line numbers
set expandtab           " Use spaces instead of tabs
set tabstop=4           " Tab width
set shiftwidth=4        " Indent width
set smartindent         " Auto indent
set wrap                " Wrap lines
set ignorecase          " Case insensitive search
set smartcase           " Case sensitive when uppercase present
set incsearch           " Incremental search
set hlsearch            " Highlight search results
set termguicolors       " True color support
set clipboard=unnamedplus " System clipboard
set mouse=a             " Enable mouse
set updatetime=300      " Faster completion
set timeoutlen=500      " Faster key sequence completion

" Color scheme
set background=dark
colorscheme gruvbox

" Key mappings
let mapleader = " "

" NERDTree
nnoremap <leader>n :NERDTreeToggle<CR>
nnoremap <leader>f :NERDTreeFind<CR>

" FZF
nnoremap <leader>p :Files<CR>
nnoremap <leader>b :Buffers<CR>
nnoremap <leader>g :Rg<CR>

" Window navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Clear search highlight
nnoremap <leader>/ :nohlsearch<CR>

" Save and quit
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>

" Auto-save on focus lost
autocmd FocusLost * silent! wa

" Remove trailing whitespace on save
autocmd BufWritePre * :%s/\s\+$//e

" Editor options
set nocompatible
set mouse=a
set number
set relativenumber
set splitbelow
set splitright
set incsearch
set hlsearch
set ignorecase
set smartcase
set confirm
set hidden
set autoread
set belloff=all
set completeopt=menuone,noselect
set shortmess+=cI
set helplang=ja,en
set laststatus=3
set updatetime=100
set timeoutlen=300
set ttimeoutlen=10
set grepprg=rg\ --vimgrep\ --hidden\ --glob\ '!.git'
set grepformat=%f:%l:%c:%m
set termguicolors
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
set t_ut=
set t_RB=
set background=dark
set cursorline
if exists('&cursorlineopt')
  set cursorlineopt=number
endif

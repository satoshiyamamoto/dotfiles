call plug#begin(stdpath('data') . '/plugged')
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/async.vim'
Plug 'prabirshrestha/vim-lsp'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
Plug 'mattn/vim-lsp-settings'
Plug 'mattn/vim-goimports'
Plug 'mattn/emmet-vim'
Plug 'ryanolsonx/vim-lsp-javascript'
Plug 'hashivim/vim-terraform' , { 'for': 'terraform' }
Plug 'editorconfig/editorconfig-vim'
Plug 'dense-analysis/ale'
Plug 'prettier/vim-prettier', { 'do': 'yarn install' }
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'scrooloose/nerdcommenter'
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'ryanoasis/vim-devicons'
Plug 'luochen1990/rainbow'
Plug 'joshdick/onedark.vim'
Plug 'morhetz/gruvbox'
Plug 'haishanh/night-owl.vim'
Plug 'artanikin/vim-synthwave84'
Plug 'tomasr/molokai'
call plug#end()

colorscheme synthwave84

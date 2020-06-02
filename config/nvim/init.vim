" Basics
set number

" Plug-ins
call plug#begin(stdpath('data') . '/plugged')
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/async.vim'
Plug 'prabirshrestha/vim-lsp'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
Plug 'mattn/vim-lsp-settings'
Plug 'mattn/vim-goimports'
Plug 'mattn/emmet-vim'
Plug 'ryanolsonx/vim-lsp-javascript'
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
Plug 'ryanoasis/vim-devicons'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'luochen1990/rainbow'
Plug 'joshdick/onedark.vim'
Plug 'morhetz/gruvbox'
Plug 'haishanh/night-owl.vim'
Plug 'artanikin/vim-synthwave84'
Plug 'tomasr/molokai'
call plug#end()

" Colors
set termguicolors
colorscheme synthwave84


" Mappings
noremap  <C-p>          :Files<CR>
noremap  <silent><C-\>  :NERDTreeToggle<CR>
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <CR>    pumvisible() ? "\<C-y>" : "\<CR>"

" Plugin Configurations
let g:airline_theme='minimalist'
let g:airline#extensions#branch#enabled = 1
let g:rainbow_active = 1
let g:rainbow_conf = {
\	'separately': {
\		'nerdtree': 0
\	}
\}
let g:ale_linters = {
	\ 'go': ['gopls'],
	\}


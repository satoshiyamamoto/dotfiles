set number
set updatetime=100

" Plugins
call plug#begin(stdpath('data') . '/plugged')
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/async.vim'
Plug 'prabirshrestha/vim-lsp'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
Plug 'hrsh7th/vim-vsnip'
Plug 'hrsh7th/vim-vsnip-integ'
Plug 'mattn/vim-lsp-settings'
Plug 'mattn/vim-goimports'
Plug 'mattn/emmet-vim'
Plug 'luochen1990/rainbow'
Plug 'jiangmiao/auto-pairs'
Plug 'editorconfig/editorconfig-vim'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'scrooloose/nerdcommenter'
Plug 'scrooloose/nerdtree'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'ryanoasis/vim-devicons'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'artanikin/vim-synthwave84'
Plug 'haishanh/night-owl.vim'
Plug 'joshdick/onedark.vim'
Plug 'morhetz/gruvbox'
Plug 'tomasr/molokai'
call plug#end()

" Plugin Configurations
let g:airline_theme='minimalist'
let g:airline#extensions#branch#enabled = 1
let g:rainbow_active = 1
let g:rainbow_conf = {
\	'separately': {
\		'nerdtree': 0
\	}
\}

" Mappings
noremap  <C-p>             :Files<CR>
noremap  <F2>              :LspRename<CR>
noremap  <F12>             :LspDefinition<CR>
noremap  <F24>             :LspReferences<CR>
noremap  <silent><Leader>e :NERDTreeToggle<CR>
inoremap <expr> <Tab>      pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab>    pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <CR>       pumvisible() ? "\<C-y>" : "\<CR>"

" Colors
set termguicolors
colorscheme synthwave84
highlight GitGutterAdd    guifg=#009900 ctermfg=2
highlight GitGutterChange guifg=#bbbb00 ctermfg=3
highlight GitGutterDelete guifg=#ff2222 ctermfg=1


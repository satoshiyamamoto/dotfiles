" Plugin manager (vim-plug)
" Install vim-plug if not found
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
      \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif

call plug#begin()
" language server & completion
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/async.vim'
Plug 'prabirshrestha/vim-lsp'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
Plug 'prabirshrestha/asyncomplete-buffer.vim'
Plug 'prabirshrestha/asyncomplete-file.vim'
Plug 'mattn/vim-lsp-settings'
Plug 'lighttiger2505/sqls.vim'
" snippet
Plug 'hrsh7th/vim-vsnip'
Plug 'hrsh7th/vim-vsnip-integ'
Plug 'rafamadriz/friendly-snippets'
Plug 'mattn/vim-goimports'
Plug 'mattn/emmet-vim'
Plug 'jiangmiao/auto-pairs'
Plug 'easymotion/vim-easymotion'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-unimpaired'
" formatter
Plug 'editorconfig/editorconfig-vim'
Plug 'prettier/vim-prettier', {
    \ 'do': 'yarn install --frozen-lockfile --production',
    \ 'for': ['javascript', 'typescript', 'css', 'json',
    \         'markdown', 'vue', 'yaml', 'html'] }
Plug 'google/vim-maktaba'
Plug 'google/vim-codefmt'
Plug 'google/vim-glaive'
" finder
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'preservim/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'ryanoasis/vim-devicons'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
" theme
Plug 'folke/tokyonight.nvim'
Plug 'satoshiyamamoto/vim-github-dark'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'airblade/vim-gitgutter'
Plug 'luochen1990/rainbow'
call plug#end()

" Run PlugInstall if there are missing plugins
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
    \| PlugInstall --sync | source $MYVIMRC
    \| endif

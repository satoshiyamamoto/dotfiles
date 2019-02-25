" ~/.vim/plugins.vim

if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')
" Plugins
Plug 'Shougo/neocomplcache.vim'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'tpope/vim-endwise', {'for': 'ruby'}
Plug 'tpope/vim-rails', {'for': ['ruby', 'eruby']}
Plug 'mattn/emmet-vim', {'for': ['html','eruby']}
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
" Languages
Plug 'digitaltoad/vim-pug', {'for': ['jade', 'pug']}
Plug 'dNitro/vim-pug-complete', {'for': ['jade', 'pug']}
Plug 'scrooloose/nerdtree', {'on': 'NERDTreeToggle'}
Plug 'scrooloose/syntastic'
Plug 'jaxbot/syntastic-react'
Plug 'hashivim/vim-terraform'
" Themes
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'flazz/vim-colorschemes'
Plug 'chriskempson/vim-tomorrow-theme'
Plug 'whatyouhide/vim-gotham'
Plug 'joshdick/onedark.vim'
Plug 'sheerun/vim-polyglot'
Plug 'tfnico/vim-gradle'
call plug#end()


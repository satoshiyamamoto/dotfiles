" ~/.vim/plugins.vim

if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')
" Plugins
Plug 'Shougo/neocomplcache.vim'
Plug 'tpope/vim-endwise', {'for': 'ruby'}
Plug 'tpope/vim-rails', {'for': ['ruby', 'eruby']}
Plug 'pangloss/vim-javascript', {'for': 'javascript'}
Plug 'othree/javascript-libraries-syntax.vim', {'for': 'javascript'}
Plug 'digitaltoad/vim-pug', {'for': ['jade', 'pug']}
Plug 'dNitro/vim-pug-complete', {'for': ['jade', 'pug']}
Plug 'mxw/vim-jsx', {'for': 'javascript'}
Plug 'burnettk/vim-angular', {'for': ['javascript','html']}
Plug 'moll/vim-node', {'for': 'javascript'}
Plug 'othree/html5.vim'
Plug 'fatih/vim-go', {'for': 'go'}
Plug 'elzr/vim-json', {'for': 'json'}
Plug 'digitaltoad/vim-pug'
Plug 'mattn/emmet-vim', {'for': ['html','eruby']}
Plug 'ctrlpvim/ctrlp.vim'
Plug 'scrooloose/nerdtree', {'on': 'NERDTreeToggle'}
Plug 'scrooloose/syntastic'
Plug 'jaxbot/syntastic-react'
" Color schemes
Plug 'flazz/vim-colorschemes'
Plug 'chriskempson/vim-tomorrow-theme'
Plug 'whatyouhide/vim-gotham'
call plug#end()


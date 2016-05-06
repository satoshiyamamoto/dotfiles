" An example for a vimrc file.
"
" Maintainer:    Bram Moolenaar <Bram@vim.org>
" Last change:    2008 Jul 02
"
" To use it, copy it to
"     for Unix and OS/2:  ~/.vimrc

" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
  finish
endif

" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

set nobackup        " do not keep a backup file, use versions instead
set history=50      " keep 50 lines of command line history
set ruler           " show the cursor position all the time
set showcmd         " display incomplete commands
set hlsearch        " highlight search keywords
set incsearch       " do incremental searching
set showmatch       " display brachets in code
set autoindent      " keep previous indent
set smarttab
set tabstop=4
set shiftwidth=4
set encoding=utf-8
set fileencodings=iso-2022-jp,cp932,sjis,euc-jp,utf-8

" Don't use Ex mode, use Q for formatting
map Q gq

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78
  autocmd FileType html setlocal tabstop=2 softtabstop=2 shiftwidth=2
  autocmd FileType javascript,ruby,eruby setlocal expandtab tabstop=2 softtabstop=2 shiftwidth=2

  " Complete a close tag input for XML and HTML files.
  augroup MyXML
    autocmd!
      autocmd FileType xml,html inoremap <buffer> </ </<C-x><C-o>
  augroup END

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  " Also don't do it when the mark is in the first line, that is the default
  " position when opening a file.
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

  augroup END

else

  set autoindent        " always set autoindenting on

endif " has("autocmd")

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
          \ | wincmd p | diffthis
endif

" NeoBundle plugin management.
" - If the plugin is not already installed.
" $ curl https://raw.githubusercontent.com/Shougo/neobundle.vim/master/bin/install.sh | sh
"
if isdirectory(expand('$HOME/.vim/bundle/neobundle.vim/'))

  if has('vim_starting')
    if &compatible
      set nocompatible               " Be iMproved
    endif
  
    " Required:
    set runtimepath+=$HOME/.vim/bundle/neobundle.vim/
  endif
  
  " Required:
  call neobundle#begin(expand('$HOME/.vim/bundle'))
  
  " Let NeoBundle manage NeoBundle
  " Required:
  NeoBundleFetch 'Shougo/neobundle.vim'
  NeoBundle 'Shougo/neosnippet.vim'
  NeoBundle 'Shougo/neosnippet-snippets'
  NeoBundle has('lua') 
        \ ? 'Shougo/neocomplete'
        \ : 'Shougo/neocomplcache'
  NeoBundle 'tpope/vim-fugitive'
  NeoBundle 'tpope/vim-surround'
  NeoBundle 'tpope/vim-endwise'
  NeoBundle 'tpope/vim-rails'
  NeoBundle 'pangloss/vim-javascript', {'rev': 'develop'}
  NeoBundle 'othree/javascript-libraries-syntax.vim'
  NeoBundle 'othree/html5.vim'
  NeoBundle 'moll/vim-node'
  NeoBundle 'mattn/emmet-vim'
  NeoBundle 'ctrlpvim/ctrlp.vim'
  NeoBundle 'scrooloose/nerdtree'
  NeoBundle 'flazz/vim-colorschemes'
  NeoBundle 'altercation/vim-colors-solarized'
  
  " Required:
  call neobundle#end()
  
  " Required:
  filetype plugin indent on
  
  " If there are uninstalled bundles found on startup,
  " this will conveniently prompt you to install them.
  NeoBundleCheck
  
  nnoremap <silent> <C-\> :NERDTreeToggle<CR>
  
endif " isdirectory(expand('$HOME/.vim/bundle/neobundle.vim/'))

" Appearance settings. (Color and Fonts)
"
" when managing a colorscheme under NeoBundle, 
" must specify after the NeoBundle settings.
"
syntax on

if has('gui_running')
  set background=light
else
  set background=dark
endif

try
  colorscheme solarized
  set t_Co=256
  let g:solarized_termcolors=256
  let g:solarized_termtrans=1
catch
  set t_Co=16
  colorscheme default
endtry

" NeoComplcache settings. (Require: if_lua option.)
" see: https://github.com/Shougo/neocomplcache.vim
"
if isdirectory(expand('$HOME/.vim/bundle/neocomplcache'))

  let g:acp_enableAtStartup = 0                 " Disable AutoComplPop.
  let g:neocomplcache_enable_at_startup = 1        " Use neocomplcache.
  let g:neocomplcache_enable_smart_case = 1        " Use smartcase.
  let g:neocomplcache_min_syntax_length = 3        " Set minimum syntax keyword length.
  let g:neocomplcache_lock_buffer_name_pattern = '\*ku\*'
  " Enable heavy features.
  "let g:neocomplcache_enable_camel_case_completion = 1  " Use camel case completion.
  "let g:neocomplcache_enable_underbar_completion = 1    " Use underbar completion.
  
  " Define dictionary.
  let g:neocomplcache_dictionary_filetype_lists = {
    \ 'default' : '',
    \ 'vimshell' : $HOME.'/.vimshell_hist',
    \ 'scheme' : $HOME.'/.gosh_completions'
      \ }
  
  " Define keyword.
  if !exists('g:neocomplcache_keyword_patterns')
    let g:neocomplcache_keyword_patterns = {}
  endif
  let g:neocomplcache_keyword_patterns['default'] = '\h\w*'
  
  " Plugin key-mappings.
  inoremap <expr><C-g>     neocomplcache#undo_completion()
  inoremap <expr><C-l>     neocomplcache#complete_common_string()
  
  " Recommended key-mappings.
  " <CR>: close popup and save indent.
  inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
  function! s:my_cr_function()
    return neocomplcache#smart_close_popup() . "\<CR>"
    " For no inserting <CR> key.
    "return pumvisible() ? neocomplcache#close_popup() : "\<CR>"
  endfunction
  " <TAB>: completion.
  inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
  " <C-h>, <BS>: close popup and delete backword char.
  inoremap <expr><C-h> neocomplcache#smart_close_popup()."\<C-h>"
  inoremap <expr><BS> neocomplcache#smart_close_popup()."\<C-h>"
  inoremap <expr><C-y>  neocomplcache#close_popup()
  inoremap <expr><C-e>  neocomplcache#cancel_popup()
  
  " Enable omni completion.
  autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
  autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
  autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
  autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
  autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
  " Enable heavy omni completion.
  if !exists('g:neocomplcache_force_omni_patterns')
    let g:neocomplcache_force_omni_patterns = {}
  endif
  let g:neocomplcache_force_omni_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
  let g:neocomplcache_force_omni_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
  let g:neocomplcache_force_omni_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'
  
endif " isdirectory(expand('$HOME/.vim/bundle/neocomplcache'))

" NeoComplete settings.
" see: https://github.com/Shougo/neocomplete.vim
"
if isdirectory(expand('$HOME/.vim/bundle/neocomplete'))

  let g:acp_enableAtStartup = 0           " Disable AutoComplPop.
  let g:neocomplete#enable_at_startup = 1 " Use neocomplete.
  let g:neocomplete#enable_smart_case = 1 " Use smartcase.
  let g:neocomplete#sources#syntax#min_keyword_length = 3 " Set minimum syntax keyword length.
  let g:neocomplete#lock_buffer_name_pattern = '\*ku\*'
  
  " Define dictionary.
  let g:neocomplete#sources#dictionary#dictionaries = {
    \ 'default' : '',
    \ 'vimshell' : $HOME.'/.vimshell_hist',
    \ 'scheme' : $HOME.'/.gosh_completions'
      \ }
  
  " Define keyword.
  if !exists('g:neocomplete#keyword_patterns')
      let g:neocomplete#keyword_patterns = {}
  endif
  let g:neocomplete#keyword_patterns['default'] = '\h\w*'
  
  " Plugin key-mappings.
  inoremap <expr><C-g>     neocomplete#undo_completion()
  inoremap <expr><C-l>     neocomplete#complete_common_string()
  
  " Recommended key-mappings.
  " <CR>: close popup and save indent.
  inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
  function! s:my_cr_function()
    return neocomplete#close_popup() . "\<CR>"
    " For no inserting <CR> key.
    "return pumvisible() ? neocomplete#close_popup() : "\<CR>"
  endfunction
  " <TAB>: completion.
  inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
  " <C-h>, <BS>: close popup and delete backword char.
  inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
  inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
  inoremap <expr><C-y>  neocomplete#close_popup()
  inoremap <expr><C-e>  neocomplete#cancel_popup()
  
  " Enable omni completion.
  autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
  autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
  autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
  autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
  autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
  
  " Enable heavy omni completion.
  if !exists('g:neocomplete#sources#omni#input_patterns')
    let g:neocomplete#sources#omni#input_patterns = {}
  endif
  "let g:neocomplete#sources#omni#input_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
  "let g:neocomplete#sources#omni#input_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
  "let g:neocomplete#sources#omni#input_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'
 
endif " isdirectory(expand('$HOME/.vim/bundle/neocomplete'))

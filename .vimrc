" An example for a vimrc file.
"
" Maintainer:	Bram Moolenaar <Bram@vim.org>
" Last change:	2006 Aug 12
"
" To use it, copy it to
"     for Unix and OS/2:  ~/.vimrc
"	      for Amiga:  s:.vimrc
"  for MS-DOS and Win32:  $VIM\_vimrc
"	    for OpenVMS:  sys$login:.vimrc

" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
  finish
endif

" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

" show line number
"set number

if has("vms")
  set nobackup		" do not keep a backup file, use versions instead
else
  " set backup		" keep a backup file
endif
set history=50		" keep 50 lines of command line history
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set incsearch		" do incremental searching

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")

" Don't use Ex mode, use Q for formatting
map Q gq

" In an xterm the mouse should work quite well, thus enable it.
set mouse=a

" This is an alternative that also works in block mode, but the deleted
" text is lost and it only works for putting the current register.
"vnoremap p "_dp

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
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

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif

  augroup END

else

  set autoindent		" always set autoindenting on

endif " has("autocmd")

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
	 	\ | wincmd p | diffthis


" Apearance
"----------
syntax enable
colorscheme molokai
set noexpandtab
set tabstop=2
set shiftwidth=2
set softtabstop=0


" Plugin Management
"------------------
" NeoBundle
if has('vim_starting')
	set nocompatible               " Be iMproved

	" Required:
	set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

" Required:
call neobundle#begin(expand('~/.vim/bundle/'))

" Let NeoBundle manage NeoBundle
" Required:
NeoBundleFetch 'Shougo/neobundle.vim'

" My Bundles here:
NeoBundle 'Shougo/neosnippet.vim'
NeoBundle 'Shougo/neosnippet-snippets'
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'kien/ctrlp.vim'
NeoBundle 'flazz/vim-colorschemes'
NeoBundle 'Shougo/neocomplete.vim'

" You can specify revision/branch/tag.
NeoBundle 'Shougo/vimshell', { 'rev' : '3787e5' }

call neobundle#end()

" Required:
filetype plugin indent on

" If there are uninstalled bundles found on startup,
" this will conveniently prompt you to install them.
NeoBundleCheck

""Note: This option must set it in .vimrc(_vimrc).  NOT IN .gvimrc(_gvimrc)!
""" Disable AutoComplPop.
"let g:acp_enableAtStartup = 0
"" Use neocomplete.
"let g:neocomplete#enable_at_startup = 1
"" Use smartcase.
"let g:neocomplete#enable_smart_case = 1
"" Set minimum syntax keyword length.
"let g:neocomplete#sources#syntax#min_keyword_length = 3
"let g:neocomplete#lock_buffer_name_pattern = '\*ku\*'
"
"" Define dictionary.
"let g:neocomplete#sources#dictionary#dictionaries = {
"			\ 'default' : '',
"			\ 'vimshell' : $HOME.'/.vimshell_hist',
"			\ 'scheme' : $HOME.'/.gosh_completions'
"			\ }
"
"" Define keyword.
"if !exists('g:neocomplete#keyword_patterns')
"	let g:neocomplete#keyword_patterns = {}
"endif
"let g:neocomplete#keyword_patterns['default'] = '\h\w*'
"
"" Plugin key-mappings.
"inoremap <expr><C-g>     neocomplete#undo_completion()
"inoremap <expr><C-l>     neocomplete#complete_common_string()
"
"" Recommended key-mappings.
"" <CR>: close popup and save indent.
"inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
"function! s:my_cr_function()
"	return neocomplete#close_popup() . "\<CR>"
"	" For no inserting <CR> key.
"	"return pumvisible() ? neocomplete#close_popup() : "\<CR>"
"endfunction
"" <TAB>: completion.
"inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
"" <C-h>, <BS>: close popup and delete backword char.
"inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
"inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
"inoremap <expr><C-y>  neocomplete#close_popup()
"inoremap <expr><C-e>  neocomplete#cancel_popup()
"" Close popup by <Space>.
""inoremap <expr><Space> pumvisible() ? neocomplete#close_popup() : "\<Space>"
"
"
"" For cursor moving in insert mode(Not recommended)
""inoremap <expr><Left>  neocomplete#close_popup() . "\<Left>"
""inoremap <expr><Right> neocomplete#close_popup() . "\<Right>"
""inoremap <expr><Up>    neocomplete#close_popup() . "\<Up>"
""inoremap <expr><Down>  neocomplete#close_popup() . "\<Down>"
"" Or set this.
""let g:neocomplete#enable_cursor_hold_i = 1
"" Or set this.
""let g:neocomplete#enable_insert_char_pre = 1
"
"" AutoComplPop like behavior.
""let g:neocomplete#enable_auto_select = 1
"
"" Shell like behavior(not recommended).
""set completeopt+=longest
""let g:neocomplete#enable_auto_select = 1
""let g:neocomplete#disable_auto_complete = 1
""inoremap <expr><TAB>  pumvisible() ? "\<Down>" : "\<C-x>\<C-u>"
""
"" Enable omni completion.
"autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
"autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
"autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
"autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
"autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
""
"" Enable heavy omni completion.
"if !exists('g:neocomplete#sources#omni#input_patterns')
"	let g:neocomplete#sources#omni#input_patterns = {}
"endif
""let g:neocomplete#sources#omni#input_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
""let g:neocomplete#sources#omni#input_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
""let g:neocomplete#sources#omni#input_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'
"
"" For perlomni.vim setting.
"" https://github.com/c9s/perlomni.vim
"let g:neocomplete#sources#omni#input_patterns.perl ='\h\w*->\h\w*\|\h\w*::'"

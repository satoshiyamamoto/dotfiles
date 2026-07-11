" Global key mappings
"" Windows
tnoremap <Esc>              <C-W>N
tnoremap <C-[>              <C-W>N
nnoremap <silent><C-/>      :bo terminal ++close ++rows=12<CR>
" Ctrl+/ arrives as ^_ (<C-_>) over SSH/legacy terminals
nmap     <C-_>              <C-/>
"" Buffers
nnoremap <silent><Esc>      :noh<CR>
nnoremap <silent><C-[>      :noh<CR>
nnoremap <silent><Leader>bd :bprevious<Bar>bdelete #<CR>
nnoremap <silent><Leader>bo :%bdelete<Bar>edit #<Bar>bdelete #<CR>
nnoremap <silent>[c         <Plug>(GitGutterPrevHunk)<CR>
nnoremap <silent>]c         <Plug>(GitGutterNextHunk)<CR>
nmap     <silent>s          <Plug>(easymotion-s2)
nmap     <silent>S          <Plug>(easymotion-bd-w)
"" Pickers
nnoremap <silent><C-P>      :Files<CR>
nmap     <Leader><Leader>   <C-P>
nnoremap <silent><Leader>/  :Rg<CR>
nnoremap <silent><Leader>,  :Buffers<CR>
nnoremap <silent><Leader>e  :NERDTreeToggle<CR>
nnoremap <silent><Leader>r  :NERDTreeRefreshRoot<CR>
nnoremap <silent><Leader>n  :NERDTreeFind<CR>
"" IME
inoremap <C-S-J>            <Nop>
inoremap <C-S-;>            <Nop>

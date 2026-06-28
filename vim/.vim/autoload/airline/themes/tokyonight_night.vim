" tokyonight_night - a vim-airline theme
"
" Structure follows the base16 airline theme; colors follow folke/tokyonight.nvim
" "night" as mapped by its lualine theme (lua/lualine/themes/_tokyonight.lua):
"   a/z (mode)   : black text on the mode accent color
"   b/y (info)   : mode accent text on fg_gutter
"   c/x (middle) : fg_sidebar text on bg_statusline

let g:airline#themes#tokyonight_night#palette = {}

" --- tokyonight "night" palette: [gui, cterm] -----------------------------
let s:blue    = ['#7aa2f7', 111]  " normal mode
let s:green   = ['#9ece6a', 150]  " insert mode
let s:magenta = ['#bb9af7', 141]  " visual mode
let s:red     = ['#f7768e', 210]  " replace mode

let s:black     = ['#15161e', 234]  " text on the mode blocks (a/z)
let s:fg_gutter = ['#3b4261', 238]  " background of info blocks (b/y)
let s:bg_stl    = ['#16161e', 233]  " background of middle blocks (c/x)
let s:fg_side   = ['#a9b1d6', 146]  " text of middle blocks (c/x)
let s:orange    = ['#ff9e64', 215]  " modified-buffer indicator

" Build a full color-map from a single mode accent, mirroring the lualine theme.
function! s:mode(accent) abort
  let l:a = [s:black[0],   a:accent[0],    s:black[1],   a:accent[1]]
  let l:b = [a:accent[0],  s:fg_gutter[0], a:accent[1],  s:fg_gutter[1]]
  let l:c = [s:fg_side[0], s:bg_stl[0],    s:fg_side[1], s:bg_stl[1]]
  return airline#themes#generate_color_map(l:a, l:b, l:c)
endfunction

let g:airline#themes#tokyonight_night#palette.normal  = s:mode(s:blue)
let g:airline#themes#tokyonight_night#palette.insert  = s:mode(s:green)
let g:airline#themes#tokyonight_night#palette.replace = s:mode(s:red)
let g:airline#themes#tokyonight_night#palette.visual  = s:mode(s:magenta)

" Modified buffer: tint the middle section's text orange.
let s:modified = {
      \ 'airline_c': [s:orange[0], s:bg_stl[0], s:orange[1], s:bg_stl[1], 'bold'],
      \ }
let g:airline#themes#tokyonight_night#palette.normal_modified  = s:modified
let g:airline#themes#tokyonight_night#palette.insert_modified  = s:modified
let g:airline#themes#tokyonight_night#palette.replace_modified = s:modified
let g:airline#themes#tokyonight_night#palette.visual_modified  = s:modified

" Inactive window: dim everything onto the statusline background.
let s:ia_a = [s:blue[0],      s:bg_stl[0], s:blue[1],      s:bg_stl[1]]
let s:ia_b = [s:fg_gutter[0], s:bg_stl[0], s:fg_gutter[1], s:bg_stl[1]]
let s:ia_c = [s:fg_gutter[0], s:bg_stl[0], s:fg_gutter[1], s:bg_stl[1]]
let g:airline#themes#tokyonight_night#palette.inactive =
      \ airline#themes#generate_color_map(s:ia_a, s:ia_b, s:ia_c)
let g:airline#themes#tokyonight_night#palette.inactive_modified = {
      \ 'airline_c': [s:orange[0], '', s:orange[1], '', 'bold'],
      \ }

" Accents (readonly, etc.).
let g:airline#themes#tokyonight_night#palette.accents = {
      \ 'red': [s:red[0], '', s:red[1], ''],
      \ }

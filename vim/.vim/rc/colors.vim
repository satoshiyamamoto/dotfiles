" Colorscheme and highlight overrides

""
" Post-colorscheme highlight overrides: transparency and CursorLine underline.
function! s:OverrideHighlights() abort
  highlight Normal       ctermbg=NONE guibg=NONE
  highlight SignColumn   ctermbg=NONE guibg=NONE
  highlight LineNr       ctermbg=NONE guibg=NONE
  highlight CursorLineNr ctermbg=NONE guibg=NONE guifg=#737aa2 cterm=NONE term=NONE
  highlight FoldColumn   ctermbg=NONE guibg=NONE
  highlight Pmenu        ctermbg=NONE guibg=NONE
  highlight PmenuSbar    ctermbg=NONE guibg=NONE
  highlight PmenuThumb   ctermbg=NONE guibg=NONE
  highlight CursorLine   term=NONE cterm=NONE gui=NONE
endfunction

augroup highlight_overrides
  autocmd!
  autocmd ColorScheme * call s:OverrideHighlights()
augroup END

set rtp+=~/.vim/plugged/tokyonight.nvim/extras/vim
colorscheme tokyonight-night

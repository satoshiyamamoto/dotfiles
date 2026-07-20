" Language server (vim-lsp + mattn/vim-lsp-settings)
let g:lsp_settings_filetype_python = 'pyright-langserver'
let g:lsp_settings = {
\   'gopls': {
\     'capabilities': {
\       'textDocument': {
\         'documentSymbol': { 'hierarchicalDocumentSymbolSupport': v:true },
\         'completion': { 'completionItem': { 'snippetSupport': v:true } },
\       },
\     },
\   },
\   'typescript-language-server': {
\     'workspace_config':
\       { 'completions': { 'completeFunctionCalls': v:true } },
\   },
\ }

let g:lsp_diagnostics_signs_error = {'text': ''}
let g:lsp_diagnostics_signs_warning = {'text': ''}
let g:lsp_diagnostics_signs_information = {'text': ''}
let g:lsp_diagnostics_signs_hint = {'text': ''}
let g:lsp_diagnostics_virtual_text_enabled = 0
let g:lsp_diagnostics_echo_cursor = 1

function! s:OnLspBufferEnabled() abort
  setlocal omnifunc=lsp#complete
  setlocal signcolumn=yes
  if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif
  nmap <buffer> gd <Plug>(lsp-definition)
  nmap <buffer> gO <Plug>(lsp-document-symbol-search)
  nmap <buffer> grr <Plug>(lsp-references)
  nmap <buffer> gri <Plug>(lsp-implementation)
  nmap <buffer> grt <Plug>(lsp-type-definition)
  nmap <buffer> grn <Plug>(lsp-rename)
  nmap <buffer> gra <Plug>(lsp-code-action)
  nmap <buffer> [d <Plug>(lsp-previous-diagnostic)
  nmap <buffer> ]d <Plug>(lsp-next-diagnostic)
  nmap <buffer> K <Plug>(lsp-hover)
  nmap <buffer> <Leader>f <Plug>(lsp-document-format)
  inoremap <buffer> <expr><C-F> lsp#scroll(+4)
  inoremap <buffer> <expr><C-D> lsp#scroll(-4)

  " let g:lsp_format_sync_timeout = 1000
  " autocmd! BufWritePre *.rs,*.go call execute('LspDocumentFormatSync')
endfunction

augroup lsp_install
  autocmd!
  autocmd User lsp_buffer_enabled call s:OnLspBufferEnabled()
augroup END

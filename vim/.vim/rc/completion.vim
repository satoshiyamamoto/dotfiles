" Completion (asyncomplete) and snippets (vsnip)

""
" Strips the auto-inserted closing pair character from a candidate's word.
function! s:AsyncompleteStripPairCharacters(base, item) abort
  let l:item = a:item
  let l:pair = { '"': '"', '''': '''' }
  if !empty(a:base) && has_key(l:pair, a:base[0])
    let [l:lhs, l:rhs, l:str] =
    \   [a:base[0], l:pair[a:base[0]], get(l:item, 'word', '')]
    if len(l:str) > 1 && l:str[0] ==# l:lhs && l:str[-1:] ==# l:rhs
      let l:item = extend({}, l:item)
      let l:item['word'] = l:str[:-2]
    endif
  endif
  return l:item
endfunction

""
" Turns a pyright function completion into a "name($0)" snippet to insert ().
function! s:PyrightFunctionCallSnippet(source_name, item) abort
  if a:source_name !=# 'asyncomplete_lsp_pyright-langserver'
    return a:item
  endif
  if index(['function', 'method', 'constructor'], get(a:item, 'kind', '')) < 0
    return a:item
  endif
  let l:word = get(a:item, 'word', '')
  if empty(l:word) || l:word =~# '[()]$'
    return a:item
  endif

  let l:item = extend({}, a:item)
  let l:managed = lsp#omni#get_managed_user_data_from_completed_item(a:item)
  let l:completion_item =
  \   copy(get(l:managed, 'completion_item', { 'label': l:word }))
  let l:snippet = l:word . '($0)'

  if has_key(l:completion_item, 'textEdit')
  \   && type(l:completion_item['textEdit']) == type({})
    let l:completion_item['textEdit'] = copy(l:completion_item['textEdit'])
    let l:completion_item['textEdit']['newText'] = l:snippet
  else
    let l:completion_item['insertText'] = l:snippet
  endif
  let l:completion_item['insertTextFormat'] = 2

  let l:item['abbr'] = get(l:item, 'abbr', l:word) . '()'
  let l:item['user_data'] =
  \   json_encode({ 'lsp': { 'completion_item': l:completion_item } })
  return l:item
endfunction

""
" Applies pair-stripping then the pyright () snippet transform to a candidate.
function! s:ProcessItem(source_name, base, item) abort
  return s:PyrightFunctionCallSnippet(
  \   a:source_name, s:AsyncompleteStripPairCharacters(a:base, a:item))
endfunction

""
" Default asyncomplete preprocessor plus the pyright () snippet transform.
function! s:AsyncompletePreprocessor(options, matches) abort
  let l:items = []
  let l:startcols = []
  for [l:source_name, l:matches] in items(a:matches)
    let l:startcol = l:matches['startcol']
    let l:base = a:options['typed'][l:startcol - 1:]
    let l:source = asyncomplete#get_source_info(l:source_name)

    if has_key(l:source, 'filter')
      let l:result = l:source.filter(l:matches, l:startcol, l:base)
      for l:item in l:result[0]
        call add(l:items, s:PyrightFunctionCallSnippet(l:source_name, l:item))
      endfor
      let l:startcols += l:result[1]
    elseif empty(l:base)
      for l:item in l:matches['items']
        call add(l:items, s:ProcessItem(l:source_name, l:base, l:item))
        let l:startcols += [l:startcol]
      endfor
    elseif exists('*matchfuzzypos')
    \   && get(g:, 'asyncomplete_matchfuzzy', exists('*matchfuzzypos'))
      for l:item in
      \   matchfuzzypos(l:matches['items'], l:base, { 'key': 'word' })[0]
        call add(l:items, s:ProcessItem(l:source_name, l:base, l:item))
        let l:startcols += [l:startcol]
      endfor
    else
      for l:item in l:matches['items']
        if stridx(l:item['word'], l:base) == 0
          call add(l:items, s:ProcessItem(l:source_name, l:base, l:item))
          let l:startcols += [l:startcol]
        endif
      endfor
    endif
  endfor

  if !empty(l:startcols)
    let a:options['startcol'] = min(l:startcols)
  endif
  call asyncomplete#preprocess_complete(a:options, l:items)
endfunction
let g:asyncomplete_preprocessor = [function('s:AsyncompletePreprocessor')]

" Snippet expand/jump
imap <expr><C-J> vsnip#expandable() ? '<Plug>(vsnip-expand)'         : '<C-J>'
smap <expr><C-J> vsnip#expandable() ? '<Plug>(vsnip-expand)'         : '<C-J>'
imap <expr><C-L> vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<C-L>'
smap <expr><C-L> vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<C-L>'

augroup asyncomplete_sources
  autocmd!
  autocmd User asyncomplete_setup call asyncomplete#register_source(
      \ asyncomplete#sources#buffer#get_source_options({
      \   'name': 'buffer',
      \   'allowlist': ['*'],
      \   'priority': 15,
      \   'completor': function('asyncomplete#sources#buffer#completor'),
      \   'config': { 'max_buffer_size': 1000000 },
      \ }))
  autocmd User asyncomplete_setup call asyncomplete#register_source(
      \ asyncomplete#sources#file#get_source_options({
      \   'name': 'file',
      \   'allowlist': ['*'],
      \   'priority': 10,
      \   'completor': function('asyncomplete#sources#file#completor'),
      \ }))
augroup END

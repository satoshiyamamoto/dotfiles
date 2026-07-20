" Auto-format on save (google/vim-codefmt)
augroup autoformat_settings
  autocmd!
  autocmd FileType bzl AutoFormatBuffer buildifier
  autocmd FileType c,cpp,proto,arduino AutoFormatBuffer clang-format
  autocmd FileType dart AutoFormatBuffer dartfmt
  autocmd FileType gn AutoFormatBuffer gn
  autocmd FileType java AutoFormatBuffer google-java-format
  autocmd FileType python AutoFormatBuffer black
  autocmd FileType rust AutoFormatBuffer rustfmt
augroup END

augroup prettier_format
  autocmd!
  autocmd BufWritePre *.js,*.cjs,*.mjs,*.jsx,*.ts,*.cts,*.mts,*.tsx,*.css,*.html,*.json,*.jsonc
      \ Prettier
augroup END

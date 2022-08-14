-- vim:foldmethod=marker

-- Basic: {{{

vim.g.mapleader = ' '

vim.opt.mouse = 'a'
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.termguicolors = true
vim.opt.confirm = true
vim.opt.completeopt = 'menu,menuone,noselect'
vim.opt.clipboard:append { 'unnamedplus' }
vim.opt.updatetime = 100
--vim.opt_global.shortmess:remove('F'):append('c')

-- }}}

-- Plugins: {{{

local install_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  packer_bootstrap = vim.fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim',
    install_path })
  vim.cmd [[packadd packer.nvim]]
end

require('packer').startup(function(use)
  use { 'wbthomason/packer.nvim' }

  -- language server
  use { 'neovim/nvim-lspconfig' }
  use { 'williamboman/mason.nvim' }
  use { 'williamboman/mason-lspconfig.nvim' }
  use { 'nanotee/sqls.nvim' }

  -- debugger
  use { 'mfussenegger/nvim-dap' }
  use { 'mfussenegger/nvim-dap-python' }
  use { 'mfussenegger/nvim-jdtls' }
  use { 'theHamsta/nvim-dap-virtual-text' }
  use { 'rcarriga/nvim-dap-ui' }
  use { 'leoluz/nvim-dap-go' }
  use { 'microsoft/java-debug' }
  use { 'vim-test/vim-test' }

  -- completion
  use { 'hrsh7th/cmp-nvim-lsp' }
  use { 'hrsh7th/cmp-buffer' }
  use { 'hrsh7th/cmp-path' }
  use { 'hrsh7th/cmp-cmdline' }
  use { 'hrsh7th/nvim-cmp' }
  use { 'hrsh7th/cmp-vsnip' }
  use { 'hrsh7th/vim-vsnip' }
  use { 'hrsh7th/vim-vsnip-integ' }
  use { 'onsails/lspkind-nvim' }
  use { 'golang/vscode-go' }

  -- syntax highlight
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
  use { 'nvim-treesitter/nvim-treesitter-textobjects' }
  use { 'nvim-treesitter/nvim-treesitter-refactor' }
  use { 'nvim-lua/plenary.nvim' }
  use { 'p00f/nvim-ts-rainbow' }
  use { 'lukas-reineke/indent-blankline.nvim' }
  use { 'lukas-reineke/virt-column.nvim' }

  -- formatter
  use { 'editorconfig/editorconfig-vim' }
  use { 'google/vim-maktaba' }
  use { 'google/vim-codefmt' }
  use { 'google/vim-glaive' }
  use { 'prettier/vim-prettier', run = 'yarn install',
    ft = { 'javascript', 'typescript', 'css', 'less', 'scss', 'json', 'html' } }
  use { 'mattn/vim-goimports' }

  -- snippet
  use { 'rafamadriz/friendly-snippets' }
  use { 'windwp/nvim-autopairs' }
  use { 'tpope/vim-fugitive' }
  use { 'tpope/vim-surround' }
  use { 'tpope/vim-commentary' }
  use { 'tpope/vim-unimpaired' }
  use { 'mattn/emmet-vim' }

  -- finder
  use { 'phaazon/hop.nvim' }
  use { 'nvim-telescope/telescope.nvim' }
  use { 'nvim-telescope/telescope-frecency.nvim' }
  use { 'nvim-telescope/telescope-ui-select.nvim' }
  use { 'ryanoasis/vim-devicons' }
  use { 'kyazdani42/nvim-web-devicons' }
  use { 'kyazdani42/nvim-tree.lua' }
  use { 'tami5/sqlite.lua' }

  -- theme
  use { 'projekt0n/github-nvim-theme' }
  use { 'nvim-lualine/lualine.nvim' }
  use { 'rcarriga/nvim-notify' }
  use { 'airblade/vim-gitgutter' }
  use { 'akinsho/bufferline.nvim', tag = 'v2.*' }
  use { 'akinsho/toggleterm.nvim', tag = 'v2.*' }

  if packer_bootstrap then
    require('packer').sync()
  end
end)

-- }}}

-- Notifications: {{{

require('notify').setup({
  background_colour = '#000000',
})
vim.notify = require('notify')

-- }}}

-- Mappings: {{{

local opts = { noremap = true, silent = true }

-- Insert
vim.keymap.set('i', 'jj', '<Esc>', opts)

-- Terminal
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', opts)
vim.keymap.set('t', '<C-[>', '<C-\\><C-n>', opts)

-- Buffers
vim.keymap.set('n', '[b', '<Cmd>:bprevious<CR>', opts)
vim.keymap.set('n', ']b', '<Cmd>:bnext<CR>', opts)
vim.keymap.set('n', '[B', '<Cmd>:bfirst<CR>', opts)
vim.keymap.set('n', ']B', '<Cmd>:blast<CR>', opts)

-- Windows
vim.keymap.set('n', '<C-j>', '<C-w>j', opts)
vim.keymap.set('n', '<C-k>', '<C-w>k', opts)
vim.keymap.set('n', '<C-h>', '<C-w>h', opts)
vim.keymap.set('n', '<C-l>', '<C-w>l', opts)

-- Diagnostics
vim.keymap.set('n', '<Leader>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<Leader>q', vim.diagnostic.setloclist, opts)

-- Debuggers
local dap = require('dap')
local dapui = require('dapui')
vim.keymap.set('n', '<F5>', dap.continue, opts)
vim.keymap.set('n', '<F10>', dap.step_over, opts)
vim.keymap.set('n', '<F11>', dap.step_into, opts)
vim.keymap.set('n', '<F23>', dap.step_out, opts)
vim.keymap.set('n', '<Leader>b', dap.toggle_breakpoint, opts)
vim.keymap.set('n', '<Leader>B', function()
  dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, opts)
vim.keymap.set('n', '<Leader>lp', function()
  dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
end, opts)
vim.keymap.set('n', '<Leader>du', dapui.toggle, opts)

-- Hop (easymotion)
vim.keymap.set('n', '<Leader><Leader>w', '<Cmd>HopWord<CR>', opts)
vim.keymap.set('n', '<Leader><Leader>f', '<Cmd>HopChar1<CR>', opts)

-- Telescope
local telescope = require('telescope')
local telescope_builtin = require('telescope.builtin')
vim.keymap.set('n', '<Leader>ff', telescope_builtin.find_files, opts)
vim.keymap.set('n', '<leader>fg', telescope_builtin.live_grep, opts)
vim.keymap.set('n', '<leader>fb', telescope_builtin.buffers, opts)
vim.keymap.set('n', '<leader>fh', telescope_builtin.help_tags, opts)
vim.keymap.set('n', '<leader>fr', telescope.extensions.frecency.frecency, opts)

-- NvimTree
vim.keymap.set('n', '<C-n>', '<Cmd>NvimTreeToggle<CR>', opts)
vim.keymap.set('n', '<Leader>r', '<Cmd>NvimTreeRefresh<CR>', opts)
vim.keymap.set('n', '<Leader>n', '<Cmd>NvimTreeFindFile<CR>', opts)

-- Snippets
vim.cmd([[
imap <expr> <C-j>   vsnip#expandable()  ? '<Plug>(vsnip-expand)'         : '<C-j>'
smap <expr> <C-j>   vsnip#expandable()  ? '<Plug>(vsnip-expand)'         : '<C-j>'
imap <expr> <C-l>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'
smap <expr> <C-l>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'
imap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
smap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
imap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'
smap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'
]])

-- }}}

-- LSP: {{{

require('mason').setup()
require('mason-lspconfig').setup()

local lspconfig = require('lspconfig')

local on_attach = function(_, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local bufopts = { noremap = true, silent = true, buffer = bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', 'gs', vim.lsp.buf.document_symbol, bufopts)
  vim.keymap.set('n', 'gS', vim.lsp.buf.workspace_symbol, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<Space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set('n', '<Space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set('n', '<Space>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  vim.keymap.set('n', '<Space>D', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<Space>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<Space>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<Space>f', vim.lsp.buf.formatting, bufopts)
end

-- Language servers
lspconfig['gopls'].setup { on_attach = on_attach }
lspconfig['pyright'].setup { on_attach = on_attach }
lspconfig['tsserver'].setup { on_attach = on_attach }
lspconfig['terraformls'].setup { on_attach = on_attach }
lspconfig['rust_analyzer'].setup { on_attach = on_attach }
lspconfig['sqls'].setup {
  on_attach = function(client, bufnr)
    require('sqls').on_attach(client, bufnr)
  end
}
lspconfig['intelephense'].setup {
  on_attach = on_attach,
  init_options = {
    globalStoragePath = vim.fn.stdpath('cache') .. '/intelephense',
    licenceKey = vim.fn.stdpath('config') .. '/../intelephense/licence.key'
  }
}
lspconfig['sumneko_lua'].setup {
  on_attach = on_attach,
  settings = {
    Lua = {
      diagnostics = {
        globals = { 'vim', 'require' }
      }
    }
  }
}

-- }}}

-- DAP: {{{

local mason_path = vim.fn.stdpath('data') .. '/mason'
require('dap-go').setup()
require('dap-python').setup(
  mason_path .. '/packages/debugpy/venv/bin/python'
)
dap.adapters.php = {
  type = 'executable',
  command = mason_path .. '/bin/php-debug-adapter',
}
dap.configurations.php = {
  {
    type = 'php',
    request = 'launch',
    name = 'Listen for Xdebug',
    port = 9003
  }
}
dapui.setup()
dap.listeners.after.event_initialized['dapui_config'] = function()
  dapui.open()
end
dap.listeners.before.event_terminated['dapui_config'] = function()
  dapui.close()
end
dap.listeners.before.event_exited['dapui_config'] = function()
  dapui.close()
end

-- }}}

-- Completions: {{{

local cmp = require('cmp')

cmp.setup {
  snippet = {
    expand = function(args)
      vim.fn['vsnip#anonymous'](args.body) -- For `vsnip` users.
    end,
  },
  mapping = {
    ['<C-p>']     = cmp.mapping.select_prev_item(),
    ['<C-n>']     = cmp.mapping.select_next_item(),
    ['<C-d>']     = cmp.mapping.scroll_docs(-4),
    ['<C-f>']     = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>']     = cmp.mapping.close(),
    ['<CR>']      = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
    ['<Tab>']     = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
    ['<S-Tab>']   = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'vsnip' }, -- For vsnip users.
  }, {
    { name = 'buffer' },
    { name = 'path' },
  }),
  formatting = {
    format = require('lspkind').cmp_format({
      mode = 'symbol_text',
      maxwidth = 50,
      preset = 'default',
    }),
  },
}

-- Use buffer source for `/`
cmp.setup.cmdline('/', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':'
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})

-- Complete the bracket with 'CR'
cmp.event:on('confirm_done', require('nvim-autopairs.completion.cmp').on_confirm_done())

require('nvim-autopairs').setup {}

-- }}}

-- Syntax: {{{

require('nvim-treesitter.configs').setup {
  ensure_installed = { 'c', 'go', 'java', 'javascript', 'typescript', 'python', 'php', 'pug', 'hcl', 'lua', 'rust',
    'yaml' },
  highlight = {
    enable = true,
    disable = {},
    additional_vim_regex_highlighting = { 'php', 'yaml' },
  },
  rainbow = {
    enable = true,
    extended_mode = true,
    max_file_lines = nil,
  },
}

require('indent_blankline').setup {
  space_char_blankline = ' ',
  show_current_context = true,
  show_current_context_start = true,
}
require('virt-column').setup()

-- }}}

-- Finder: {{{

require('hop').setup {}

telescope.setup {
  defaults = {
    path_display = {
      truncate = 0,
    },
    file_ignore_patterns = {
      'node_modules',
      '%.class',
    }
  },
  extensions = {
    ['ui-select'] = {
      require('telescope.themes').get_dropdown {}
    }
  }
}
telescope.load_extension('frecency')
telescope.load_extension('ui-select')

require('nvim-tree').setup {
  view = {
    hide_root_folder = true,
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = true,
  }
}

-- }}}

-- Terminal: {{{

require("toggleterm").setup {
  open_mapping = [[<Leader>`]],
  insert_mappings = true,
}
vim.keymap.set('n', '<Leader>lg', function()
  require('toggleterm.terminal').Terminal:new({
    cmd = "lazygit",
    direction = 'float',
    hidden = true,
    count = 0
  }):toggle()
end)

vim.cmd([[
autocmd TermOpen * startinsert
autocmd TermOpen * setlocal nonumber norelativenumber
]])

-- }}}

-- Formatting: {{{

vim.cmd([[
autocmd FileType bzl AutoFormatBuffer buildifier
autocmd FileType c,cpp,proto,arduino AutoFormatBuffer clang-format
autocmd FileType dart AutoFormatBuffer dartfmt
autocmd FileType go AutoFormatBuffer gofmt
autocmd FileType gn AutoFormatBuffer gn
autocmd FileType javascript,html,css,sass,scss,less,json AutoFormatBuffer prettier
autocmd FileType java AutoFormatBuffer google-java-format
autocmd FileType python AutoFormatBuffer yapf
autocmd FileType rust AutoFormatBuffer rustfmt
]])

-- }}}

-- Theme: {{{

require('github-theme').setup({
  theme_style = 'dark_default',
  function_style = 'italic',
  sidebars = { 'qf', 'vista_kind', 'terminal', 'packer' },
  transparent = true,
})

require('lualine').setup {
  options = { theme = 'auto' }
}

require('bufferline').setup {
  options = {
    offsets = {
      {
        filetype = 'NvimTree',
      }
    }
  }
}

vim.cmd([[
highlight clear ColorColumn
highlight WinSeparator guifg=#2f363e
setglobal laststatus=3
]])

--- }}}

-- Functions: {{{

-- Utility functions shared between progress reports for LSP and DAP
local client_notifs = {}

local function get_notif_data(client_id, token)
  if not client_notifs[client_id] then
    client_notifs[client_id] = {}
  end

  if not client_notifs[client_id][token] then
    client_notifs[client_id][token] = {}
  end

  return client_notifs[client_id][token]
end

local spinner_frames = { "⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷" }

local function update_spinner(client_id, token)
  local notif_data = get_notif_data(client_id, token)

  if notif_data.spinner then
    local new_spinner = (notif_data.spinner + 1) % #spinner_frames
    notif_data.spinner = new_spinner

    notif_data.notification = vim.notify(nil, nil, {
      hide_from_history = true,
      icon = spinner_frames[new_spinner],
      replace = notif_data.notification,
    })

    vim.defer_fn(function()
      update_spinner(client_id, token)
    end, 100)
  end
end

local function format_title(title, client_name)
  return client_name .. (#title > 0 and ": " .. title or "")
end

local function format_message(message, percentage)
  return (percentage and percentage .. "%\t" or "") .. (message or "")
end

-- LSP integration
-- Make sure to also have the snippet with the common helper functions in your config!

vim.lsp.handlers["$/progress"] = function(_, result, ctx)
  local client_id = ctx.client_id

  local val = result.value

  if not val.kind then
    return
  end

  local notif_data = get_notif_data(client_id, result.token)

  if val.kind == "begin" then
    local message = format_message(val.message, val.percentage)

    notif_data.notification = vim.notify(message, "info", {
      title = format_title(val.title, vim.lsp.get_client_by_id(client_id).name),
      icon = spinner_frames[1],
      timeout = false,
      hide_from_history = false,
    })

    notif_data.spinner = 1
    update_spinner(client_id, result.token)
  elseif val.kind == "report" and notif_data then
    notif_data.notification = vim.notify(format_message(val.message, val.percentage), "info", {
      replace = notif_data.notification,
      hide_from_history = false,
    })
  elseif val.kind == "end" and notif_data then
    notif_data.notification = vim.notify(val.message and format_message(val.message) or "Complete", "info", {
      icon = "",
      replace = notif_data.notification,
      timeout = 3000,
    })

    notif_data.spinner = nil
  end
end

-- DAP integration
-- Make sure to also have the snippet with the common helper functions in your config!

dap.listeners.before['event_progressStart']['progress-notifications'] = function(session, body)
  local notif_data = get_notif_data("dap", body.progressId)

  local message = format_message(body.message, body.percentage)
  notif_data.notification = vim.notify(message, "info", {
    title = format_title(body.title, session.config.type),
    icon = spinner_frames[1],
    timeout = false,
    hide_from_history = false,
  })

  notif_data.notification.spinner = 1
  update_spinner("dap", body.progressId)
end

dap.listeners.before['event_progressUpdate']['progress-notifications'] = function(session, body)
  local notif_data = get_notif_data('dap', body.progressId)
  notif_data.notification = vim.notify(format_message(body.message, body.percentage), 'info', {
    replace = notif_data.notification,
    hide_from_history = false,
  })
end

dap.listeners.before['event_progressEnd']['progress-notifications'] = function(session, body)
  local notif_data = client_notifs['dap'][body.progressId]
  notif_data.notification = vim.notify(body.message and format_message(body.message) or 'Complete', 'info', {
    icon = '',
    replace = notif_data.notification,
    timeout = 3000
  })
  notif_data.spinner = nil
end

-- }}}

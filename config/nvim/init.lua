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
end

require('packer').startup(function(use)
  use { 'wbthomason/packer.nvim' }

  -- language server
  use { 'neovim/nvim-lspconfig' }
  use { 'williamboman/nvim-lsp-installer' }
  use { 'nanotee/sqls.nvim' }

  -- debugger
  use { 'mfussenegger/nvim-dap' }
  use { 'mfussenegger/nvim-dap-python' }
  use { 'mfussenegger/nvim-jdtls' }
  use { 'leoluz/nvim-dap-go' }
  use { 'theHamsta/nvim-dap-virtual-text' }
  use { 'rcarriga/nvim-dap-ui' }
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

  -- syntax highlight
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
  use { 'nvim-treesitter/nvim-treesitter-textobjects' }
  use { 'nvim-treesitter/nvim-treesitter-refactor' }
  use { 'nvim-lua/plenary.nvim' }
  use { 'p00f/nvim-ts-rainbow' }

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
  use { 'nvim-telescope/telescope-ui-select.nvim' }
  use { 'ryanoasis/vim-devicons' }
  use { 'kyazdani42/nvim-web-devicons' }
  use { 'kyazdani42/nvim-tree.lua' }

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

-- Mappings: {{{

local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }
-- LSP
map('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
map('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
map('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
map('n', 'gi', '<Cmd>lua vim.lsp.buf.implementation()<CR>', opts)
map('n', 'gs', '<Cmd>lua vim.lsp.buf.document_symbol()<CR>', opts)
map('n', 'gS', '<Cmd>lua vim.lsp.buf.workspace_symbol()<CR>', opts)
map('n', '<C-k>', '<Cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
map('n', '<Space>wa', '<Cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
map('n', '<Space>wr', '<Cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
map('n', '<Space>wl', '<Cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
map('n', '<Space>D', '<Cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
map('n', '<Space>rn', '<Cmd>lua vim.lsp.buf.rename()<CR>', opts)
map('n', '<Space>ca', '<Cmd>lua vim.lsp.buf.code_action()<CR>', opts)
map('n', 'gr', '<Cmd>lua vim.lsp.buf.references()<CR>', opts)
map('n', '<Space>f', '<Cmd>lua vim.lsp.buf.formatting()<CR>', opts)
-- Debuggers
map('n', '<F5>', '<Cmd>lua require"dap".continue()<CR>', opts)
map('n', '<F10>', '<Cmd>lua require"dap".step_over()<CR>', opts)
map('n', '<F11>', '<Cmd>lua require"dap".step_into()<CR>', opts)
map('n', '<F12>', '<Cmd>lua require"dap".step_out()<CR>', opts)
map('n', '<Leader>b', '<Cmd>lua require"dap".toggle_breakpoint()<CR>', opts)
map('n', '<Leader>B', '<Cmd>lua require"dap".set_breakpoint(vim.fn.input("Breakpoint condition: "))<CR>', opts)
map('n', '<Leader>lp', '<Cmd>lua require"dap".set_breakpoint(nil, nil, vim.fn.input("Log point message: "))<CR>', opts)
map('n', '<Leader>dr', '<Cmd>lua require"dap".repl.open()<CR>', opts)
map('n', '<Leader>dl', '<Cmd>lua require"dap".run_last()<CR>', opts)
-- Diagnostics
map('n', '<Space>e', '<Cmd>lua vim.diagnostic.open_float()<CR>', opts)
map('n', '[d', '<Cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
map('n', ']d', '<Cmd>lua vim.diagnostic.goto_next()<CR>', opts)
map('n', '<Space>q', '<Cmd>lua vim.diagnostic.setloclist()<CR>', opts)
-- Test
map('n', '<Leader>t', '<Cmd>TestNearest<CR>', opts)
map('n', '<Leader>T', '<Cmd>TestFile<CR>', opts)
map('n', '<Leader>a', '<Cmd>TestSuite<CR>', opts)
map('n', '<Leader>l', '<Cmd>TestLast<CR>', opts)
map('n', '<Leader>g', '<Cmd>TestVisit<CR>', opts)
-- Hop (easymotion)
map('n', '<Leader><Leader>w', '<Cmd>HopWord<CR>', opts)
map('n', '<Leader><Leader>f', '<Cmd>HopChar1<CR>', opts)
-- Telescope
map('n', '<Leader>ff', '<Cmd>Telescope find_files<CR>', opts)
map('n', '<Leader>fg', '<Cmd>Telescope live_grep<CR>', opts)
map('n', '<Leader>fb', '<Cmd>Telescope buffers<CR>', opts)
map('n', '<Leader>fh', '<Cmd>Telescope help_tags<CR>', opts)
map('n', '<C-p>', '<Cmd>Telescope find_files<CR>', opts)
-- NvimTree
map('n', '<C-n>', '<Cmd>NvimTreeToggle<CR>', opts)
map('n', '<Leader>r', '<Cmd>NvimTreeRefresh<CR>', opts)
map('n', '<Leader>n', '<Cmd>NvimTreeFindFile<CR>', opts)
-- buffers
map('n', '[b', '<Cmd>:bprevious<CR>', opts)
map('n', ']b', '<Cmd>:bnext<CR>', opts)
map('n', '[B', '<Cmd>:bfirst<CR>', opts)
map('n', ']B', '<Cmd>:blast<CR>', opts)
-- Windwos
map('n', '<C-j>', '<C-w>j', opts)
map('n', '<C-k>', '<C-w>k', opts)
map('n', '<C-h>', '<C-w>h', opts)
map('n', '<C-l>', '<C-w>l', opts)
-- Insert
map('i', 'jj', '<Esc>', opts)
-- Terminal
map('t', '<Esc>', '<C-\\><C-n>', opts)

-- }}}

-- LSP: {{{

require('nvim-lsp-installer').setup {}

local lspconfig = require('lspconfig')

local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
end

-- Language servers
lspconfig.sumneko_lua.setup {
  on_attach = on_attach,
  settings = {
    Lua = {
      diagnostics = {
        globals = { 'vim' }
      }
    }
  }
}
lspconfig.sqls.setup {
  on_attach = function(client, bufnr)
    require('sqls').on_attach(client, bufnr)
  end
}
lspconfig.gopls.setup { on_attach = on_attach }
lspconfig.pyright.setup { on_attach = on_attach }
lspconfig.tsserver.setup { on_attach = on_attach }
lspconfig.terraformls.setup { on_attach = on_attach }
lspconfig.rust_analyzer.setup { on_attach = on_attach }

-- }}}

-- DAP: {{{

require('dap-python').setup('~/.local/share/virtualenvs/debugpy/bin/python')
require('dap-go').setup()
require('dapui').setup()
local dap, dapui = require("dap"), require("dapui")
dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
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
      maxwidth = 30,
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
cmp.event:on('confirm_done',
  require('nvim-autopairs.completion.cmp').on_confirm_done({
    map_char = { tex = '' }
  })
)

require('nvim-autopairs').setup {}

-- }}}

-- Syntax: {{{

require('nvim-treesitter.configs').setup {
  ensure_installed = { 'c', 'go', 'java', 'javascript', 'typescript', 'python', 'hcl', 'lua', 'rust', 'yaml' },
  highlight = {
    enable = true,
    disable = {},
  },
  rainbow = {
    enable = true,
    extended_mode = true,
    max_file_lines = nil,
  }
}

-- }}}

-- Finder: {{{

require('hop').setup {}

require('telescope').setup {
  defaults = {
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
require('telescope').load_extension('ui-select')

require('nvim-tree').setup {
  view = {
    hide_root_folder = true,
  },
  filters = {
    dotfiles = true,
  }
}
vim.g.nvim_tree_group_empty = 1

-- }}}

-- Terminal: {{{

require("toggleterm").setup {
  open_mapping = [[<Leader>`]],
  insert_mappings = false,
}

vim.keymap.set('n', '<Leader>g', function()
  require('toggleterm.terminal').Terminal:new({
    cmd = "lazygit",
    direction = 'float',
    hidden = true,
    count = 0
  }):toggle()
end)

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
  colorscheme github_dark_default
  setglobal laststatus=3
  highlight WinSeparator guifg=#2f363e
]])

--- }}}

-- Notifications: {{{

vim.notify = require('notify')

-- Output of Command
local function notify_output(command, opts)
  local output = ""
  local notification
  local notify = function(msg, level)
    local notify_opts = vim.tbl_extend(
      "keep",
      opts or {},
      { title = table.concat(command, " "), replace = notification }
    )
    notification = vim.notify(msg, level, notify_opts)
  end
  local on_data = function(_, data)
    output = output .. table.concat(data, "\n")
    notify(output, "info")
  end
  vim.fn.jobstart(command, {
    on_stdout = on_data,
    on_stderr = on_data,
    on_exit = function(_, code)
      if #output == 0 then
        notify("No output of command, exit code: " .. code, "warn")
      end
    end,
  })
end

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

-- }}}

vim.g.mapleader = ' '

vim.opt.mouse = 'a'
vim.opt.number = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.completeopt = 'menu,menuone,noselect'
vim.opt.updatetime = 100

local install_path = vim.fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  packer_bootstrap = vim.fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end

require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'

  -- language server
  use 'neovim/nvim-lspconfig'
  use 'williamboman/nvim-lsp-installer'

  -- completion
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-cmdline'
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-vsnip'
  use 'hrsh7th/vim-vsnip'
  use 'onsails/lspkind-nvim'

  -- syntax highlight
  use {'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'}
  use 'nvim-treesitter/nvim-treesitter-textobjects'
  use 'nvim-treesitter/nvim-treesitter-refactor'
  use 'p00f/nvim-ts-rainbow'

  -- formatter
  use 'editorconfig/editorconfig-vim'
  use 'google/vim-maktaba'
  use 'google/vim-codefmt'
  use 'google/vim-glaive'
  use {'prettier/vim-prettier', run = 'yarn install', ft = {'javascript', 'typescript', 'css', 'less', 'scss', 'json', 'graphql', 'markdown', 'vue', 'svelte', 'yaml', 'html'}}
  use 'mattn/vim-goimports'

  -- snippet
  use 'rafamadriz/friendly-snippets'
  use 'windwp/nvim-autopairs'
  use 'tpope/vim-fugitive'
  use 'tpope/vim-surround'
  use 'tpope/vim-commentary'
  use 'tpope/vim-unimpaired'
  use 'mattn/emmet-vim'

  -- finder
  use 'easymotion/vim-easymotion'
  use 'nvim-lua/plenary.nvim'
  use 'nvim-telescope/telescope.nvim'
  use 'ryanoasis/vim-devicons'
  use 'kyazdani42/nvim-web-devicons'
  use 'kyazdani42/nvim-tree.lua'

  -- theme
  use 'projekt0n/github-nvim-theme'
  use 'nvim-lualine/lualine.nvim'
  use 'airblade/vim-gitgutter'
  use {'akinsho/bufferline.nvim', branch = 'main'}

  if packer_bootstrap then
    require('packer').sync()
  end
end)

-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local map = vim.api.nvim_set_keymap
local opts = { noremap=true, silent=true }
map('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
map('n', '[d',       '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
map('n', ']d',       '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
map('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)

map('n', '<C-p>',      '<cmd>Telescope find_files<CR>', opts)
map('n', '<leader>ff', '<cmd>Telescope find_files<CR>', opts)
map('n', '<leader>fg', '<cmd>Telescope live_grep<CR>', opts)
map('n', '<leader>fb', '<cmd>Telescope buffers<CR>', opts)
map('n', '<leader>fh', '<cmd>Telescope help_tags<CR>', opts)

map('n', '<C-n>',     '<cmd>NvimTreeToggle<CR>', opts)
map('n', '<leader>r', '<cmd>NvimTreeRefresh<CR>', opts)
map('n', '<leader>n', '<cmd>NvimTreeFindFile<CR>', opts)

map('n', '<leader>`', '<cmd>split | wincmd j | resize 12 | terminal<CR>', opts)
map('i', 'jj', '<Esc>', opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  local bufopt = vim.api.nvim_buf_set_option
  local bufmap = vim.api.nvim_buf_set_keymap
  -- Enable completion triggered by <c-x><c-o>
  bufopt(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  bufmap(bufnr, 'n', 'gD',        '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  bufmap(bufnr, 'n', 'gd',        '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  bufmap(bufnr, 'n', 'K',         '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  bufmap(bufnr, 'n', 'gi',        '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  bufmap(bufnr, 'n', '<C-k>',     '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  bufmap(bufnr, 'n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  bufmap(bufnr, 'n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  bufmap(bufnr, 'n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  bufmap(bufnr, 'n', '<space>D',  '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  bufmap(bufnr, 'n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  bufmap(bufnr, 'n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  bufmap(bufnr, 'n', 'gr',        '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  bufmap(bufnr, 'n', '<space>f',  '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
end

require("nvim-lsp-installer").on_server_ready(function(server)
  local opts = {
    noremap = true,
    silent = true,
    on_attach = on_attach,
  }

  if server.name == 'jdtls' then
    opts.root_dir = function(fname)
      return require('lspconfig').util.root_pattern('.git', 'mvnw', 'gradlew')(fname)
    end
  end

  server:setup(opts)
  vim.cmd 'do User LspAttachBuffers'
end)

-- nvim-cmp setup
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
    format = require('lspkind').cmp_format(),
  },
}

-- Use buffer source for `/`
cmp.setup.cmdline('/', {
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':'
cmp.setup.cmdline(':', {
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

require('nvim-treesitter.configs').setup {
  ensure_installed = 'all',
  ignore_install = { 'phpdoc' },
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

require('telescope').setup {
  defaults = {
    file_ignore_patterns = { 'node_modules' }
  }
}

require('nvim-tree').setup {
  view = {
    hide_root_folder = true,
  },
  filters = {
    dotfiles = true,
  }
}
vim.g.nvim_tree_group_empty = 1

require('bufferline').setup {
  options = {
    offsets = {
      {
        filetype = 'NvimTree',
      }
    }
  }
}

require('lualine').setup {
  options = { theme = 'auto' }
}

-- terminal
vim.cmd([[
  autocmd TermOpen  * startinsert
  autocmd TermOpen  * setlocal norelativenumber
  autocmd TermOpen  * setlocal nonumber
  autocmd TermClose * call feedkeys("\<CR>")
]])

-- auto format
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

-- theme
vim.cmd([[
  colorscheme github_dark_default
  setglobal laststatus=3
  highlight WinSeparator guifg=#2f363e
]])


-- init.lua (merged first-run-safe version)

-- ---------------------------------------------------
-- 0. Bootstrap packer.nvim if not installed
-- ---------------------------------------------------
local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'

if fn.empty(fn.glob(install_path)) > 0 then
  print("📦 Installing packer.nvim...")
  fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
  vim.cmd [[packadd packer.nvim]]
end

-- Auto-compile when saving this file
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost init.lua source <afile> | PackerCompile
  augroup end
]])

-- ---------------------------------------------------
-- 1. Plugins
-- ---------------------------------------------------
require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'          -- Packer manages itself
  use 'neovim/nvim-lspconfig'           -- LSP configurations
  use 'hrsh7th/nvim-cmp'                -- Autocompletion
  use 'hrsh7th/cmp-nvim-lsp'
  use 'nvim-treesitter/nvim-treesitter' -- Treesitter syntax highlighting
  use 'nvim-lua/plenary.nvim'
  use 'nvim-telescope/telescope.nvim'
  use 'ThePrimeagen/harpoon'
  use 'rose-pine/neovim'                -- Colorscheme
end)

-- ---------------------------------------------------
-- 2. Load your existing bartleby module
-- ---------------------------------------------------
require("bartleby")
print("hello")  -- your debug / test line

-- ---------------------------------------------------
-- 3. Neovim settings
-- ---------------------------------------------------
vim.opt.signcolumn = 'yes'  -- avoid layout shift

-- ---------------------------------------------------
-- 4. LSP capabilities
-- ---------------------------------------------------
local lspconfig_defaults = require('lspconfig').util.default_config
lspconfig_defaults.capabilities = vim.tbl_deep_extend(
  'force',
  lspconfig_defaults.capabilities,
  require('cmp_nvim_lsp').default_capabilities()
)

-- ---------------------------------------------------
-- 5. LSP keymaps
-- ---------------------------------------------------
vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP actions',
  callback = function(event)
    local opts = {buffer = event.buf}

    vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
    vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
    vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
    vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
    vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
    vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
    vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
    vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
    vim.keymap.set({'n', 'x'}, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
    vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
  end,
})

-- ---------------------------------------------------
-- 6. Colorscheme
-- ---------------------------------------------------
vim.cmd [[colorscheme rose-pine]]

-- ---------------------------------------------------
-- 7. Safe first-run notes
-- ---------------------------------------------------
-- After first run:
--   :PackerSync    -> installs all plugins
--   Then reopen Neovim


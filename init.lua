-- to reload neovim config:
-- :source $MYVIMRC

require("hqhs")

-- commands
-- change to directory of current file
-- :cd %:h

-- packer -- package manager
-- :PackerStatus
-- :PackerInstall

-- treesitter -- incremental syntax parsing
-- Users of packer.nvim have reported that when using treesitter for folds, they sometimes receive an error "No folds found", or that treesitter highlighting does not apply. A workaround for this is to set the folding options in an autocmd:
-- vim.opt.foldmethod     = 'expr'
-- vim.opt.foldexpr       = 'nvim_treesitter#foldexpr()'
---WORKAROUND
-- NOTE: folds all code on buffer enter, I don't want it
-- vim.api.nvim_create_autocmd({'BufEnter','BufAdd','BufNew','BufNewFile','BufWinEnter'}, {
--   group = vim.api.nvim_create_augroup('TS_FOLD_WORKAROUND', {}),
--   callback = function()
--     vim.opt.foldmethod     = 'expr'
--     vim.opt.foldexpr       = 'nvim_treesitter#foldexpr()'
--   end
-- })
---ENDWORKAROUND
vim.filetype.add({
    extension = {
        vert = "glsl",
        frag = "glsl",
        comp = "glsl"
    }
})

require'nvim-treesitter.configs'.setup {
	-- A list of parser names, or "all" (the listed parsers MUST always be installed)
	ensure_installed = {
		"c",
		"lua", "vim", "vimdoc", "query",
		"glsl",
		"markdown", "markdown_inline",
		"javascript", "typescript",
	},

	-- Install parsers synchronously (only applied to `ensure_installed`)
	sync_install = false,

	-- Automatically install missing parsers when entering buffer
	-- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
	auto_install = false,

	---- If you need to change the installation directory of the parsers (see -> Advanced Setup)
	-- parser_install_dir = "/some/path/to/store/parsers", -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!

	highlight = {
		enable = true,

		-- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
		-- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
		-- the name of the parser)
		-- list of language that will be disabled
		-- disable = { "c", "rust" },
		-- Or use a function for more flexibility, e.g. to disable slow treesitter highlight for large files
		disable = function(lang, buf)
			local max_filesize = 1024 * 1024 -- 1 MB
			local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
			if ok and stats and stats.size > max_filesize then
				return true
			end
		end,

		-- Setting this to true will run `:h syntax` and tree-sitter at the same time.
		-- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
		-- Using this option may slow down your editor, and you may see some duplicate highlights.
		-- Instead of true it can also be a list of languages
		additional_vim_regex_highlighting = false,
	},
}

-- lsp 
-- NOTE: to make any of this work you need a language server.
-- If you don't know what that is, watch this 5 min video:
-- https://www.youtube.com/watch?v=LaS32vctfOY

-- Add cmp_nvim_lsp capabilities settings to lspconfig
-- This should be executed before you configure any language server
local lspconfig_defaults = require('lspconfig').util.default_config
lspconfig_defaults.capabilities = vim.tbl_deep_extend(
'force',
lspconfig_defaults.capabilities,
require('cmp_nvim_lsp').default_capabilities()
)

-- This is where you enable features that only work
-- if there is a language server active in the file
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

-- You'll find a list of language servers here:
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
-- These are example language servers. 
require('lspconfig').clangd.setup({})
require('lspconfig').rust_analyzer.setup({})
require('lspconfig').gopls.setup({})

-- completion 
local cmp = require('cmp')

cmp.setup({
  completion = {
    autocomplete = false
  },
	sources = {
		{name = 'nvim_lsp'},
	},
	snippet = {
		expand = function(args)
			-- You need Neovim v0.10 to use vim.snippet
			vim.snippet.expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({
    ['<C-Space>'] = cmp.mapping.complete(),
  }),
})

-- editor config
vim.opt.tabstop = 2        -- Number of spaces a tab counts for
vim.opt.shiftwidth = 2     -- Number of spaces for autoindent
vim.opt.softtabstop = 2    -- Number of spaces a tab counts for while editing
vim.opt.expandtab = true   -- Convert tabs to spaces

vim.opt.nu = false 
vim.opt.relativenumber = true
vim.opt.numberwidth = 2

vim.opt.smartindent = true
vim.opt.swapfile = false
vim.opt.backup = false

vim.opt.colorcolumn = "80"

-- Reserve a space in the gutter
vim.opt.signcolumn = 'no'

vim.g.mapleader = ' ' 

vim.keymap.set("n", "<leader>.", vim.cmd.Ex) -- view directory
vim.keymap.set('n', '<D-v>', '"+p', { noremap = true })

-- Swap Ctrl-G and Ctrl-C for normal, insert, and visual modes
-- Sorry, I'm from Emacs world
vim.keymap.set({'n', 'i', 'v'}, '<C-G>', '<C-C>', { noremap = true })
vim.keymap.set({'n', 'i', 'v'}, '<C-C>', '<C-G>', { noremap = true })

-- telescope -- fuzzy search
require('telescope').load_extension('project')

local telescope = require('telescope.builtin')

vim.keymap.set('n', '<leader>,', telescope.buffers, { desc = 'buffers' })
vim.keymap.set('n', '<leader><leader>', telescope.git_files, { desc = 'project files' })

vim.keymap.set('n', '<leader>ff', telescope.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', telescope.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fh', telescope.help_tags, { desc = 'Telescope help tags' })
vim.keymap.set('n', '<leader>si', telescope.treesitter, {})

-- projects extension
-- ## Default mappings (normal mode):
-- 
-- | Key | Description                                                   |
-- | --- | ------------------------------------------------------------- |
-- | `d` | delete currently selected project                             |
-- | `r` | rename currently selected project                             |
-- | `c` | create a project\*                                            |
-- | `s` | search inside files within your project                       |
-- | `b` | browse inside files within your project                       |
-- | `w` | change to the selected project's directory without opening it |
-- | `R` | find a recently opened file within your project               |
-- | `f` | find a file within your project (same as \<CR\>)              |
-- | `o` | change current cd scope                                       |
-- 
-- ## Default mappings (insert mode):
-- 
-- | Key     | Description                                                   |
-- | ------- | ------------------------------------------------------------- |
-- | `<c-d>` | delete currently selected project                             |
-- | `<c-v>` | rename currently selected project                             |
-- | `<c-a>` | create a project\*                                            |
-- | `<c-s>` | search inside files within your project                       |
-- | `<c-b>` | browse inside files within your project                       |
-- | `<c-l>` | change to the selected project's directory without opening it |
-- | `<c-r>` | find a recently opened file within your project               |
-- | `<c-f>` | find a file within your project (same as \<CR\>)              |
-- | `<c-o>` | change current cd scope                                       |

vim.keymap.set('n', '<leader>pp', function() require'telescope'.extensions.project.project{} end)

-- compilation
-- local compiler = require('compiler')
vim.keymap.set('n', '<leader>cc', '<cmd>OverseerToggle<cr>', { noremap = true, silent = true })

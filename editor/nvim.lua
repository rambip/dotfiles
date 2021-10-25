vim.cmd 'source ~/.vimrc'

-- git clone --depth 1 https://github.com/wbthomason/packer.nvim\
 -- ~/.local/share/nvim/site/pack/packer/start/packer.nvim

vim.cmd [[packadd packer.nvim]]
require('packer').startup(function(use)
    use 'itchyny/lightline.vim'
    use 'tpope/vim-surround'
    use 'tommcdo/vim-exchange'
    use 'tpope/vim-repeat'
    use 'tpope/vim-commentary'
    use 'justinmk/vim-sneak'

    use 'mhinz/vim-startify'

    use 'rust-lang/rust.vim'
    use 'LnL7/vim-nix'
    use 'wbthomason/packer.nvim'
    use 'neovim/nvim-lspconfig'
    use 'hrsh7th/nvim-compe'
    use {'iamcco/markdown-preview.nvim', config = "vim.call('mkdp#util#install')"}
    use 'andweeb/presence.nvim'
    use 'lambdalisue/suda.vim'
    use 'nvim-treesitter/nvim-treesitter'
    use 'nvim-treesitter/playground'
    use 'mhinz/vim-startify'
    use 'folke/tokyonight.nvim'
    use 'eddyekofo94/gruvbox-flat.nvim'
    use 'matbme/JABS.nvim'
    use 'itchyny/lightline.vim'
    use {
        'nvim-telescope/telescope.nvim',
        requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}}
    }
    use {
        'glacambre/firenvim',
        run = function() vim.fn['firenvim#install'](0) end 
    }
    use 'edwinb/idris2-vim.git'
end)

vim.g.gruvbox_flat_style = "dark"
vim.g.gruvbox_transparent = true
vim.cmd 'colorscheme gruvbox-flat'

--vim.api.nvim_set_keymap("n", "S", "<Cmd>JABSOpen<cr>", {})
vim.api.nvim_set_keymap("n", "<leader>f", "<Cmd>Telescope find_file<cr>", {})
vim.o.switchbuf='usetab'

vim.g.startify_bookmarks = {{c='conf'}}

require('compe').setup({
    enabled = true,
    -- autocompletion (popup window)
    autocomplete = true,
    -- number of letters before togle completion
    min_length = 4,
    source = {
        path = true,
        buffer = true,
        nvim_lsp = true,
    },
})


local t = function(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local check_back_space = function()
    local col = vim.fn.col('.') - 1
    if col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
        return true
    else
        return false
    end
end

-- Use (s-)tab to:
--- move to prev/next item in completion menuone
--- jump to prev/next snippet's placeholder
_G.tab_complete = function()
    if vim.fn.pumvisible() == 1 then
        return t "<C-n>"
    elseif check_back_space() then
        return t "<TAB>"
    else
        return vim.fn['compe#complete']()
    end
end

_G.s_tab_complete = function()
    if vim.fn.pumvisible() == 1 then
        return t "<C-p>"
    end
end


vim.api.nvim_set_keymap("i", "<Tab>", "v:lua.tab_complete()", {expr = true})
vim.api.nvim_set_keymap("s", "<Tab>", "v:lua.tab_complete()", {expr = true})
vim.api.nvim_set_keymap("i", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
vim.api.nvim_set_keymap("s", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})

vim.o.completeopt = "menuone,noselect"






require'nvim-treesitter.configs'.setup {
    ensure_installed = "maintained", -- one of "all", "maintained" (parsers with maintainers), or a list of languages
    highlight = {
        enable = true,
    }
}


-- _           
--| |___ _ __  
--| / __| '_ \ 
--| \__ \ |_) |
--|_|___/ .__/ 
--      |_|    

local nvim_lsp = require('lspconfig')

local on_attach = function(client, bufnr)
    local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
    local opts = { noremap=true, silent=true }
    buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
    buf_set_keymap('n', 'gt', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
    buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
    buf_set_keymap('n', ',a', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
    buf_set_keymap('n', ',i', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
    buf_set_keymap('n', ',s', '<cmd>lua vim.lsp.buf.workspace_symbol()<CR>', opts)
    buf_set_keymap('n', ',r', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
    buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
    buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
    buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
end

local lspconfig = require('lspconfig')
local configs = require('lspconfig/configs')
if not lspconfig.idris2_lsp then
  configs.idris2_lsp = {
    default_config = {
      cmd = {'idris2-lsp'}; -- if not available in PATH, provide the absolute path
      filetypes = {'idris2'};
      on_new_config = function(new_config, new_root_dir)
        new_config.cmd = {'idris2-lsp'}
        new_config.capabilities['workspace']['semanticTokens'] = {refreshSupport = true}
      end;
      root_dir = function(fname)
        local scandir = require('plenary.scandir')
        local find_ipkg_ancestor = function(fname)
          return lspconfig.util.search_ancestors(fname, function(path)
            local res = scandir.scan_dir(path, {depth=1; search_pattern='.+%.ipkg'})
            if not vim.tbl_isempty(res) then
              return path
            end
          end)
        end
        return find_ipkg_ancestor(fname) or lspconfig.util.find_git_ancestor(fname) or vim.loop.os_homedir()
      end;
      settings = {};
    };
  }
end
-- Flag to enable semantic highlightning on start, if false you have to issue a first command manually
local autostart_semantic_highlightning = false
lspconfig.idris2_lsp.setup {
  on_init = custom_init,
  on_attach = on_attach,
  --custom_attach(client) -- remove this line if you don't have a customized attach function
  autostart = false,
  handlers = {
    ['workspace/semanticTokens/refresh'] = function(err, method, params, client_id, bufnr, config)
      if autostart_semantic_highlightning then
        vim.lsp.buf_request(0, 'textDocument/semanticTokens/full',
          { textDocument = vim.lsp.util.make_text_document_params() }, nil)
      end
      return vim.NIL
    end,
    ['textDocument/semanticTokens/full'] = function(err, method, result, client_id, bufnr, config)
      -- temporary handler until native support lands
      local client = vim.lsp.get_client_by_id(client_id)
      local legend = client.server_capabilities.semanticTokensProvider.legend
      local token_types = legend.tokenTypes
      local data = result.data

      local ns = vim.api.nvim_create_namespace('nvim-lsp-semantic')
      vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
      local tokens = {}
      local prev_line, prev_start = nil, 0
      for i = 1, #data, 5 do
        local delta_line = data[i]
        prev_line = prev_line and prev_line + delta_line or delta_line
        local delta_start = data[i + 1]
        prev_start = delta_line == 0 and prev_start + delta_start or delta_start
        local token_type = token_types[data[i + 3] + 1]
        vim.api.nvim_buf_add_highlight(bufnr, ns, 'LspSemantic_' .. token_type, prev_line, prev_start, prev_start + data[i + 2])
      end
    end
  },
}

-- Set here your preferred colors for semantic values
-- vim.cmd [[highlight link LspSemantic_type Include]]   -- Type constructors
-- vim.cmd [[highlight link LspSemantic_function Identifier]] -- Functions names
-- vim.cmd [[highlight link LspSemantic_enumMember Number]]   -- Data constructors
-- vim.cmd [[highlight LspSemantic_variable guifg=gray]] -- Bound variables
-- vim.cmd [[highlight link LspSemantic_keyword Structure]]  -- Keywords

for _, lsp in ipairs({"elmls", "rust_analyzer", "tsserver", "idris2_lsp"}) do
    nvim_lsp[lsp].setup{on_attach = on_attach}
end



--     _ _                       _ 
--  __| (_)___  ___ ___  _ __ __| |
-- / _` | / __|/ __/ _ \| '__/ _` |
--| (_| | \__ \ (_| (_) | | | (_| |
-- \__,_|_|___/\___\___/|_|  \__,_|
                                 

require("presence"):setup({
    auto_update = true,
    neovim_image_text = "It's not emacs.",
    main_image = "file",
})


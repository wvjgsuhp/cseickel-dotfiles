return function()
  require("nvim-lsp-installer").setup {}

  vim.fn.sign_define("DiagnosticSignError",
    {text = "", texthl = "DiagnosticSignError"})
  vim.fn.sign_define("DiagnosticSignWarn",
    {text = "", texthl = "DiagnosticSignWarn"})
  vim.fn.sign_define("DiagnosticSignInfo",
    {text = "", texthl = "DiagnosticSignInfo"})
  vim.fn.sign_define("DiagnosticSignHint",
    {text = "", texthl = "DiagnosticSignHint"})

  vim.lsp.handlers["textDocument/hover"] =
    vim.lsp.with(vim.lsp.handlers.hover, {
      -- Use a sharp border with `FloatBorder` highlights
      border = "single",
    })

  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  capabilities.textDocument.completion.completionItem.resolveSupport = {
    properties = {
      'documentation',
      'detail',
      'additionalTextEdits',
    }
  }

  local function lsp_attach()
    require('lsp_signature').on_attach({
      bind = true,
      handler_opts = {
        border = "single"
      },
      hint_enable = false,
      hint_prefix = " ",
      floating_window = true,
      toggle_key = "<M-x>"
    })
    --vim.cmd([[
    --  augroup lsp_au
    --  autocmd! * <buffer>
    --  autocmd CursorHoldI <buffer> lua vim.lsp.buf.signature_help()
    --  augroup END
    --  ]], false)
    --
  end

  local lspconfig = require("lspconfig")

  local null_ls = require("null-ls")
  null_ls.setup({
    sources = {
      --null_ls.builtins.diagnostics.eslint_d, -- eslint or eslint_d
      --null_ls.builtins.code_actions.eslint_d, -- eslint or eslint_d
      null_ls.builtins.formatting.prettier,
      null_ls.builtins.formatting.stylua -- prettier, eslint, eslint_d, or prettierd
    },
  })
  lspconfig.jsonls.setup {
    settings = {
      json = {
        schemas = require'schemastore'.json.schemas(),
      },
    },
  }


  -- make sure to only run this once!
  local tsserver_on_attach = function(client, bufnr)
    -- disable tsserver formatting if you plan on formatting via null-ls
    client.resolved_capabilities.document_formatting = false
    client.resolved_capabilities.document_range_formatting = false

    local ts_utils = require("nvim-lsp-ts-utils")

    -- defaults
    ts_utils.setup {
      enable_import_on_completion = true,
      -- eslint
      eslint_enable_code_actions = true,
      eslint_enable_disable_comments = true,
      eslint_bin = "eslint_d",
      eslint_enable_diagnostics = false,
      eslint_opts = {},

      -- formatting
      enable_formatting = true,
      formatter = "prettier",
      formatter_opts = {},

      -- update imports on file move
      update_imports_on_move = true,
      require_confirmation_on_move = false,
      watch_dir = nil,

      -- filter diagnostics
      filter_out_diagnostics_by_severity = {},
      filter_out_diagnostics_by_code = {},
    }

    -- required to fix code action ranges and filter diagnostics
    ts_utils.setup_client(client)

    -- no default maps, so you may want to define some here
    local opts = { silent = true }
    vim.api.nvim_buf_set_keymap(bufnr, "n", ",go", ":TSLspOrganize<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", ",gR", ":TSLspRenameFile<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", ",gi", ":TSLspImportAll<CR>", opts)

    lsp_attach()
  end

  --lspconfig.setup ({
  --  capabilities = capabilities,
  --  on_attach = lsp_attach
  --})

  lspconfig.tsserver.setup({
    capabilities = capabilities,
    on_attach = tsserver_on_attach
  })

  lspconfig.sumneko_lua.setup({
    capabilities = capabilities,
    on_attach = lsp_attach,
    settings = {
      Lua = {
        version = 'LuaJIT',
        diagnostics = {
          globals = {
            'vim',
            "describe",
            "it",
            "before_each",
            "after_each",
            "pending",
          },
        }
      }
    }
  })

  local other_servers = {
    "omnisharp",
    "gopls",
    "graphql",
    "yamlls",
    "html",
    --"tailwindcss",
    --"angularls"
  }
  for _, server in ipairs(other_servers) do
    lspconfig[server].setup({
      capabilities = capabilities,
      on_attach = lsp_attach,
    })
  end

  vim.cmd [[ do User LspAttachBuffers ]]

end

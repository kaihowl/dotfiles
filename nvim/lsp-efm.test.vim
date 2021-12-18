:let g:test_success = 0

:e testscript.sh

:" Wait until the LSP server / client has established connection.
:let lsp_init =  wait(10000, 'luaeval("#vim.lsp.buf_get_clients()") != 0')
:echomsg "lsp_init: " . lsp_init

:let lsp_init =  wait(10000, 'luaeval("vim.lsp.diagnostic.get_count()") != 0')

:if luaeval("vim.lsp.diagnostic.get_count()") != 0
:  quit!
:else
:  cquit!
:endif


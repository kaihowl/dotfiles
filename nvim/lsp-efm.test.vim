:let g:test_success = 0

:e testscript.sh

:" Wait until the LSP server / client has established connection.
:let lsp_init =  wait(10000, 'luaeval("#vim.lsp.buf_get_clients()") != 0')
:echomsg "lsp_init: " . lsp_init

:let wait_for_diagnostic =  wait(30000, 'luaeval("vim.lsp.diagnostic.get_count()") != 0')

:echomsg "wait_for_diagnostic: " . wait_for_diagnostic

:if luaeval("vim.lsp.diagnostic.get_count()") == 0
:  quit!
:else
:  for line in readfile(luaeval("vim.lsp.get_log_path()"))[-20:]
:    echomsg line
:  endfor
:  for line in readfile("/tmp/efm.log")[-20:]
:    echomsg line
:  endfor
:  cquit!
:endif


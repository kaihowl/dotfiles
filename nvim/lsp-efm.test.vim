:let g:test_success = 0

:echom "Checking bash support"

:e testscript.sh

:" Wait until the LSP server / client has established connection.
:let lsp_init =  wait(10000, 'luaeval("#vim.lsp.buf_get_clients()") != 0')
:echomsg "lsp_init: " . lsp_init

:let wait_for_diagnostic =  wait(10000, 'luaeval("#vim.diagnostic.get()") != 0')

:echomsg "wait_for_diagnostic: " . wait_for_diagnostic

:if luaeval("#vim.diagnostic.get()") == 0
:  echomsg "Expected diagnostics for bash"
:  for line in readfile(luaeval("vim.lsp.get_log_path()"))[-20:]
:    echomsg line
:  endfor
:  cquit!
:endif

:echom "Checking zsh support"

:e testscript.zsh

:" Wait until the LSP server / client has established connection.
:let lsp_init =  wait(10000, 'luaeval("#vim.lsp.buf_get_clients()") != 0')
:echomsg "lsp_init: " . lsp_init

:let wait_for_diagnostic =  wait(10000, 'luaeval("#vim.diagnostic.get()") != 0')

:echomsg "wait_for_diagnostic: " . wait_for_diagnostic

:if luaeval("#vim.diagnostic.get()") == 0
:  echomsg "Expected diagnostics for zsh"
:  for line in readfile(luaeval("vim.lsp.get_log_path()"))[-20:]
:    echomsg line
:  endfor
:  cquit!
:endif

:quit!

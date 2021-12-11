:" Test completion with nvim-cmp and clangd
:e test12.cpp

:" Wait until the LSP server / client has established connection.
:let lsp_init =  wait(10000, 'luaeval("#vim.lsp.buf_get_clients()") != 0')
:echomsg "lsp_init: " . lsp_init

:" Tab complete 'inline' and select it

:" The timer_start + feedkeys with '!' to stay in insert mode was copied from YCM integration test suite
:function EscapeIt(id)
:  redraw
:  echomsg "Sending <esc> to finalize selection"
:  call feedkeys("\<esc>")
:  let inline_keyword_found = search('inline')
:  if inline_keyword_found != 0
:    echomsg "Found expected completion in text"
:    quit!
:  else
:    echomsg "Failed to find expected completion in text"
:    cquit!
:  endif
:endfunction

:function SelectIt(id)
:  redraw
:  echomsg "Waiting for nvim-cmp menu to be visible"
:  call wait(10000, 'luaeval("require\"cmp\".visible()")')
:  if !luaeval("require\"cmp\".visible()")
:    echomsg "Failed to show nvim-cmp menu, timed out"
:    cquit!
:  endif
:  call timer_start(500, funcref("EscapeIt"))
:  echomsg "Sending tab key for selection"
:  call feedkeys("\<tab>")
:endfunction

:call timer_start(500, funcref("SelectIt"))
:call feedkeys("iin", 'tx!')

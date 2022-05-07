" Tab complete 'inline' and select it

" The timer_start + feedkeys with '!' to stay in insert mode was copied from YCM integration test suite

function EscapeIt(id)
  redraw
  echomsg 'Sending <esc> to finalize selection'
  call feedkeys("\<esc>")
  call timer_start(500, funcref('ValidateIt'))
endfunction

function ValidateIt(id)
  call cursor(1,1)
  let inline_keyword_found = search('inline')
  if inline_keyword_found != 0
    echomsg 'Found expected completion in text'
    quit!
  else
    echomsg 'Failed to find expected completion in text'
    cquit!
  endif
endfunction

function TabIt(id)
  call timer_start(500, funcref('EscapeIt'))
  echomsg 'Sending tab key for selection'
  call feedkeys("\<tab>")
endfunction

function WaitIt(id)
  echomsg 'Waiting for nvim-cmp menu to be visible'
  if !luaeval("require\"cmp\".visible()")
    echomsg 'No menu shown yet, retrying'
    call timer_start(500, funcref('WaitIt'))
    return
  endif
  call timer_start(500, funcref('TabIt'))
endfunction

function TriggerIt(id)
  redraw
  " TODO(kaihowl) why is this tab needed?
  call feedkeys("\<tab>")
  call timer_start(500, funcref('WaitIt'))
endfunction

function Test()
  " Test completion with nvim-cmp and clangd
  noswap edit! test12.cpp

  " Wait until the LSP server / client has established connection.
  let lsp_init =  wait(10000, 'luaeval("#vim.lsp.buf_get_clients()") != 0')
  " echomsg "lsp_init: " . lsp_init
  call timer_start(500, funcref('TriggerIt'))
  call feedkeys('i i', 'tx')
  call feedkeys('An', 'tx!')
endfunction

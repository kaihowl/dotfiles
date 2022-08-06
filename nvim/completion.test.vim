" Tab complete 'inline' and select it

" The timer_start + feedkeys with '!' to stay in insert mode was copied from YCM integration test suite

function EscapeIt(id)
  echomsg 'running EscapeIt'
  lua vim.notify(vim.inspect(#require"cmp".get_entries()), vim.log.levels.ERROR)
  let cmp_filled =  wait(10000, "luaeval('#require\"cmp\".get_entries()') != 0")
  echomsg 'cmp_filled: ' . cmp_filled
  echomsg 'Sending tab key for selection'
  call feedkeys("\<tab>")
  echomsg 'Sending <enter> to finalize selection'
  call feedkeys("\<enter>")
  call timer_start(500, funcref('WaitForSelectionDone'))
endfunction

function WaitForSelectionDone(id)
  echomsg 'Waiting for nvim-cmp menu to vanish'
  if luaeval("require\"cmp\".visible()")
    echomsg 'Menu still shown, waiting'
    call feedkeys("\<enter>")
    call timer_start(500, funcref('WaitForSelectionDone'))
    return
  endif
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

function WaitIt(id)
  echomsg 'Waiting for nvim-cmp menu to be visible'
  if !luaeval("require\"cmp\".visible()")
    echomsg 'No menu shown yet, retrying'
    call timer_start(500, funcref('WaitIt'))
    return
  endif
  call timer_start(500, funcref('EscapeIt'))
endfunction

function TriggerIt(id)
  echomsg 'running TriggerIt'
  redraw
  echomsg 'feeding tab'
  call timer_start(500, funcref('WaitIt'))
  " Unclear why this tab is needed, this is not worth investigating.
  call feedkeys("\<tab>")
endfunction

function Test()
  echomsg 'Starting test'
  " Test completion with nvim-cmp and clangd
  noswap edit! test12.cpp

  " Wait until the LSP server / client has established connection.
  let lsp_init =  wait(10000, 'luaeval("#vim.lsp.buf_get_clients()") != 0')
  echomsg 'lsp_init: ' . lsp_init
  if lsp_init != 0
    echomsg 'Failed to establish LSP connection'
    for line in readfile(luaeval('vim.lsp.get_log_path()'))[-20:]
      echomsg line
    endfor
    return v:false
  endif

  call timer_start(500, funcref('TriggerIt'))
  echomsg 'feeding keys'
  call feedkeys('i i', 'tx')
  call feedkeys('Anl', 'tx!')
endfunction

" Completion with nvim-cmp should not select first match with <cr>
" Tab complete 'this is example text ex', hit enter, and expect 'text example'
" to not be contained in the buffer. If it were, we had selected 'example'.

" The timer_start + feedkeys with '!' to stay in insert mode was copied from YCM integration test suite
function CheckIt(id)
  redraw
  call cursor(1,1)
  echomsg "Expecting buffer to not have 'text example'"
  let unexpected_completion = search('text example')
  if unexpected_completion != 0
    echomsg 'Auto completed on <cr>. Failing.'
    cquit!
  else
    echomsg 'No auto completion on <cr>. Succeeding.'
    quit!
  endif
endfunction

function EnterIt(id)
  call timer_start(500, funcref('CheckIt'))
  echomsg 'Hitting <cr>'
  call feedkeys("\<cr>")
endfunction

function WaitIt(id)
  echomsg 'Waiting for nvim-cmp menu to be visible'
  if !luaeval("require\"cmp\".visible()")
    echomsg 'No menu shown yet, retrying'
    call timer_start(500, funcref('WaitIt'))
    return
  endif
  call timer_start(500, funcref('EnterIt'))
endfunction

function TriggerIt(id)
  redraw
  call feedkeys('ex')
  call timer_start(500, funcref('WaitIt'))
endfunction

" TODO(kaihowl) move to general helpers
function Timeout(id)
  echoerr 'Test timed out'
  cquit!
endfunction

function Test()
  call timer_start(20000, funcref('Timeout'))
  edit mytest.txt
  call timer_start(500, funcref('TriggerIt'))
  call feedkeys('ithis is example text ', 'tx!')
endfunction

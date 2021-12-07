:" Completion with nvim-cmp should not select first match with <cr>
:e mytest.txt

:" Tab complete 'this is example text ex', hit enter, and expect 'text example'
:" to not be contained in the buffer. If it were, we had selected 'example'.

:" The timer_start + feedkeys with '!' to stay in insert mode was copied from YCM integration test suite
:function CheckIt(id)
:  redraw
:  echomsg "Expecting buffer to not have 'text example'"
:  let unexpected_completion = search('text example')
:  if unexpected_completion != 0
:    echomsg "Auto completed on <cr>. Failing."
:    cquit!
:  else
:    echomsg "No auto completion on <cr>. Succeeding."
:    quit!
:  endif
:endfunction

:function EnterIt(id)
:  redraw
:  echomsg "Waiting for nvim-cmp menu to be visible"
:  call wait(10000, 'luaeval("require\"cmp\".visible()")')
:  if !luaeval("require\"cmp\".visible()")
:    echomsg "Failed to show nvim-cmp menu, timed out"
:    cquit!
:  endif
:  call timer_start(500, funcref("CheckIt"))
:  echomsg "Hitting <cr>"
:  call feedkeys("\<cr>")
:endfunction

:call timer_start(500, funcref("EnterIt"))
:call feedkeys("ithis is example text ex", 'tx!')

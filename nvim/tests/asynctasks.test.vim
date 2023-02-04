function CheckAsyncOutput(id)
  call WaitAndCheckQuickfixOutput('from parent')

  noswap find! test/child.cpp

  call timer_start(500, funcref('CheckAsyncOutput2'))
  call feedkeys(",m veryspecialte\<tab>\<cr>", 'tx!')
endfunction

function CheckAsyncOutput2(id)
  call WaitAndCheckQuickfixOutput('from parent')
  quitall!
endfunction

function WaitAndCheckQuickfixOutput(expected)
  call wait(10000, 'g:asyncrun_status == "success"')
  let qfitems = getqflist()
  if len(qfitems) != 3
    echoerr 'Not enough output'
    echoerr qfitems
    cquit!
  endif
  let output = qfitems[1]['text']
  if output !=# a:expected
    echoerr 'Expected text does not match'
    echoerr output
    cquit!
  endif
endfunction

function Test()
  " Folder test-asynctasks contains two nested root markers.
  " Make sure that the .tasks file in the cwd is driving all tasks.
  cd test-asynctasks

  noswap find! parent.cpp

  call timer_start(500, funcref('CheckAsyncOutput'))
  call feedkeys(",m veryspecialte\<tab>\<cr>", 'tx!')
endfunction

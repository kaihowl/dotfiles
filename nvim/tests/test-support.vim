function Timeout(id)
  echoerr 'Test timed out'
  if len(v:errors) != 0
    for error in v:errors
      for line in split(error,"\n")
        echoerr line
      endfor
    endfor
  endif
  cquit!
endfunction

function RunTest()
  call timer_start(40000, funcref('Timeout'))
  call Test()
endfunction

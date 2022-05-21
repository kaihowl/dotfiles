function Timeout(id)
  echoerr 'Test timed out'
  cquit!
endfunction

function RunTest()
  call timer_start(40000, funcref('Timeout'))
  call Test()
endfunction

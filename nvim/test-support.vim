function Timeout(id)
  echoerr 'Test timed out'
  cquit!
endfunction

function RunTest()
  call timer_start(20000, funcref('Timeout'))
  call Test()
endfunction

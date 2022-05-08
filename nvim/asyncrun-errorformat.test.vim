function Test()
  " Start editing file with a known errorformat that includes "%-G%*%#" to
  " drop all unmatched output
  noswap edit! something.zsh
  echomsg 'Current efm: '
  setlocal efm?
  AsyncRun echo test
  call wait(10000, 'g:asyncrun_status == "success"')
  let qfitems = len(getqflist())
  if qfitems != 3
    echoerr 'Missing the command output'
    echoerr 'Instead of header, footer, and a single line of command output'
    echoerr 'we only received ' . qfitems . ' item(s)'
    echoerr 'Command output omitted, likely wrong errorformat'
    mess
    cquit!
  endif
  echomsg 'All well'
  quitall!
endfunction

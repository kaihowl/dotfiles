function Test()
  cd test-ripgrep
  Rg \. <<
  cfirst
  "check correct line
  let line = getcurpos()[1] 
  if line != 2
    echoerr 'Incorrect line, wanted 2 but got ' . line
    cquit!
  endif
  "check correct column
  let column = getcurpos()[2] 
  if column != 29
    echoerr 'Incorrect column, wanted 29 but got ' . column
    cquit!
  endif
  "All well
  "Test space separated searches, i.e., multi word
  Rg of the
  cfirst
  "check correct line
  let line = getcurpos()[1] 
  if line != 4
    echoerr 'Incorrect line, wanted 4 but got ' . line
    cquit!
  endif
  "check correct column
  let column = getcurpos()[2] 
  if column != 22
    echoerr 'Incorrect column, wanted 22 but got ' . column
    cquit!
  endif
  "Test passing parameters to the bang version of the command
  "Should not find 'foolish' but only 'fool' when asked for a full word match with '-w'
  Rg! -w fool
  cfirst
  "check correct line
  let line = getcurpos()[1] 
  if line != 6
    echoerr 'Incorrect line, wanted 6 but got ' . line
    cquit!
  endif
  "check correct column
  let column = getcurpos()[2] 
  if column != 7
    echoerr 'Incorrect column, wanted 7 but got ' . column
    cquit!
  endif
  Rg #
  cfirst
  "check correct line
  let line = getcurpos()[1] 
  if line != 7
    echoerr 'Incorrect line, wanted 7 but got ' . line
    cquit!
  endif
  "check correct column
  let column = getcurpos()[2] 
  if column != 11
    echoerr 'Incorrect column, wanted 11 but got ' . column
    cquit!
  endif
  quitall!
endfunction

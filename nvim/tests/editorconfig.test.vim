function Test()
  noswap edit! test-editorconfig/somefile.txt
  if &textwidth == 111
  quit!
  else
    cquit!
  endif
endfunction

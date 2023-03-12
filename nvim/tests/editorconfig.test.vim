function Test()
  " TODO(kaihowl) Disabled due to #538
  quit!

  noswap edit! test-editorconfig/somefile.txt
  if &textwidth == 111
  quit!
  else
    cquit!
  endif
endfunction

function Test()
  call feedkeys('ivoid main() {}', 'x')
  call feedkeys('0w', 'x')
  " Comment out the word main
  call feedkeys('gciw', 'x')
  let current_line = getline('.')
  if match(current_line, '* main *') == -1
    echom 'Expected current_line: ' . current_line . ' to contain /* main */'
    cquit!
  endif
  quit!
endfunction

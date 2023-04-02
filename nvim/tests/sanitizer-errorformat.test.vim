function Test()
  cd test-sanitizer-errorformat
  set makeprg=bash\ -c\ \"clang++\ -O0\ -g3\ -o\ /tmp/sanitizer\ -std=c++14\ -fsanitize=address\ example.cpp\ &&\ /tmp/sanitizer\"
  noswap make
  " Lazy way of checking if error format worked:
  " Did we jump to the first error position?
  " At the end, this is all we care for.
  let line = getcurpos()[1]
  if line != 3
    echoerr 'Incorrect line, wanted 3 but got ' . line
    cquit!
  endif

  quitall!
endfunction

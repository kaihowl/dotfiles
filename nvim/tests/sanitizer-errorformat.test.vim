function RunTest()
  set makeprg=bash\ -c\ \"clang++\ -o\ /tmp/sanitizer\ -std=c++14\ -fsanitize=address\ test-sanitizer-errorformat/example.cpp\ &&\ /tmp/sanitizer\"
  make
endfunction

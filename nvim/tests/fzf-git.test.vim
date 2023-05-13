lua <<EOF
function expect_eq(expected, actual)
  if expected ~= actual then
    vim.notify("Expected: " .. tostring(expected) .. " actual: " .. tostring(actual), vim.log.levels.ERROR)
  end
  assert(expected == actual)
end

function test_it()
  local from, to = parse_rename_line(" rename somefile.txt => someother.txt (100%)")
  expect_eq(from, "somefile.txt")
  expect_eq(to, "someother.txt")

  local from, to = parse_rename_line(" rename {gdb => gdb2}/somefile.txt (90%)")
  expect_eq(from, "gdb/somefile.txt")
  expect_eq(to, "gdb2/somefile.txt")

  local from, to = parse_rename_line(" rename prefix/{gdb => gdb2}/somefile.txt (20%)")
  expect_eq(from, "prefix/gdb/somefile.txt")
  expect_eq(to, "prefix/gdb2/somefile.txt")

  local from, to = parse_rename_line(" rename prefix/{gdb.txt => gdb2.vim} (100%)")
  expect_eq(from, "prefix/gdb.txt")
  expect_eq(to, "prefix/gdb2.vim")
end
EOF

function WaitForFzf()
  call assert_equal(0, wait(10000, "&buftype == 'terminal'"), "Fail to open fzf")
endfunction

function CheckSingleFile(id)
  call WaitForFzf()

  let first_commit_line = search('first commit', 'w')
  call assert_notequal(0, first_commit_line, 'first commit not found in fzf window')

  let second_commit_line = search('second commit', 'w')
  call assert_notequal(0, second_commit_line, 'second commit not found in fzf window')

  call feedkeys("\<esc>")
endfunction

function TestSingleFile()
  " TODO(hoewelmk) clean up
  let tmpdir = systemlist(['mktemp', '-d'])[0]
  call chdir(tmpdir)
  call system(['git', 'init'])
  call writefile(['something'], 'testfile.log')
  call system(['git', 'add', 'testfile.log'])
  call system(['git', 'commit', '-m', 'first commit'])
  call writefile(['something', 'something2'], 'testfile.log')
  call system(['git', 'add', 'testfile.log'])
  call system(['git', 'commit', '-m', 'second commit'])

  call timer_start(500, funcref('CheckSingleFile'))
  call feedkeys(',gl', 'tx!')
endfunction

function Test()
  lua test_it()

  call TestSingleFile()

  if len(v:errors) != 0
    echoerr v:errors
    cquit!
  endif

  quit!
endfunction

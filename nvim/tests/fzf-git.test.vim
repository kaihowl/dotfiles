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

let g:test_dirs = []

function WaitForFzf()
  call assert_equal(0, wait(10000, '&buftype == "terminal"'), 'Fail to open fzf')
endfunction

function CdTestDir()
  let dir = systemlist(['mktemp', '-d'])[0]
  call insert(g:test_dirs, dir)
  call chdir(dir)
endfunction

function CheckAfterStartup(id)
  call WaitForFzf()

  let first_commit_line = search('first commit', 'w')
  call assert_notequal(0, first_commit_line, 'first commit not found in fzf window')

  let second_commit_line = search('second commit', 'w')
  call assert_notequal(0, second_commit_line, 'second commit not found in fzf window')

  call feedkeys("\<esc>")
endfunction

function TestAfterStartup()
  call CdTestDir()

  call system(['git', 'init'])
  call writefile(['something'], 'testfile.log')
  call system(['git', 'add', 'testfile.log'])
  call system(['git', 'commit', '-m', 'first commit'])
  call writefile(['something', 'something2'], 'testfile.log')
  call system(['git', 'add', 'testfile.log'])
  call system(['git', 'commit', '-m', 'second commit'])

  call timer_start(500, funcref('CheckAfterStartup'))
  call feedkeys(',gl', 'tx!')
endfunction

function TestNonGitDir()
  call CdTestDir()

  call feedkeys(',gl', 'tx')

  redir => s:last_message
  1messages
  redir END

  call assert_equal("\nNot in a git directory. Aborting.", s:last_message, 'Could not find error message for non-git cwd')
  call assert_notequal(&buftype, 'terminal', 'Fzf should not have been opened')
endfunction

function CheckFileInPast(id)
  call WaitForFzf()

  let first_commit_line = search('first commit', 'w')
  call assert_notequal(0, first_commit_line, 'first commit not found in fzf window')

  let first_commit_line = search('second commit', 'w')
  call assert_equal(0, first_commit_line, 'second commit found in fzf window, despite viewing history _before_ this commit')

  let unrelated_commit_line = search('unrelated commit', 'w')
  call assert_equal(0, first_commit_line, 'unrlated commit found in fzf window, despite viewing history of specific file')

  call feedkeys("\<esc>")
endfunction

function TestFileInPast()
  call CdTestDir()

  call system(['git', 'init'])
  call writefile(['something'], 'othertestfile.log')
  call system(['git', 'add', 'othertestfile.log'])
  call system(['git', 'commit', '-m', 'unrelated commit'])
  call writefile(['something'], 'testfile.log')
  call system(['git', 'add', 'testfile.log'])
  call system(['git', 'commit', '-m', 'first commit'])
  let file_first_commit = systemlist(['git', 'rev-parse', 'HEAD'])[0]
  call writefile(['something', 'something2'], 'testfile.log')
  call system(['git', 'add', 'testfile.log'])
  call system(['git', 'commit', '-m', 'second commit'])

  exe 'Gedit ' . file_first_commit . ':testfile.log'

  call timer_start(500, funcref('CheckFileInPast'))
  call feedkeys(',gl', 'tx!')
endfunction

function CheckFileChangingName(id)
  call WaitForFzf()

  let first_commit_line = search('first commit', 'w')
  call assert_notequal(0, first_commit_line, 'first commit for renamed file not in fzf window')

  let renaming_commit_line = search('renaming commit', 'w')
  call assert_notequal(0, renaming_commit_line, 'commit that renamed file not in fzf window')

  let unrelated_commit_line = search('unrelated commit', 'w')
  call assert_equal(0, unrelated_commit_line, 'unrelated commit in fzf window')

  call feedkeys("\<esc>")
endfunction

function TestFileChangingName()
  call CdTestDir()

  call system(['git', 'init'])
  call writefile(['teststuff'], 'othertestfile.log')
  call system(['git', 'add', 'othertestfile.log'])
  call system(['git', 'commit', '-m', 'unrelated commit'])
  call writefile(['something'], 'testfile.log')
  call system(['git', 'add', 'testfile.log'])
  call system(['git', 'commit', '-m', 'first commit'])
  call system(['git', 'mv', 'testfile.log', 'renamedfile.log'])
  call system(['git', 'commit', '-m', 'renaming commit'])

  edit renamedfile.log

  call timer_start(500, funcref('CheckFileChangingName'))
  call feedkeys(',gl', 'tx!')
endfunction

function CleanUpDirs()
  for dir in g:test_dirs
    echom 'Cleaning up dir ' . dir
    call delete(dir, 'rf')
  endfor
endfunction

function Test()
  lua test_it()

  call TestAfterStartup()
  call TestNonGitDir()
  call TestFileInPast()
  call TestFileChangingName()

  call CleanUpDirs()

  if len(v:errors) != 0
    echoerr v:errors
    cquit!
  endif

  quit!
endfunction

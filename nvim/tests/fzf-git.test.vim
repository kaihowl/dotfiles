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

function WaitForFzfResults(num_results)
  call assert_equal(0, wait(10000, '&buftype == "terminal"'), 'Failed to open fzf')
  call assert_equal(0, wait(10000, 'search("> .* < ' . a:num_results . '/", "w") != 0'), 'Failed to wait for fzf prompt')
endfunction

function CdTestDir()
  let dir = systemlist(['mktemp', '-d'])[0]
  call insert(g:test_dirs, dir)
  call chdir(dir)
endfunction

function CleanUpDirs()
  for dir in g:test_dirs
    echom 'Cleaning up dir ' . dir
    call delete(dir, 'rf')
  endfor
endfunction

function CheckAfterStartup(id)
  call WaitForFzfResults(2)

  let first_commit_line = search('first commit', 'w')
  call assert_notequal(0, first_commit_line, 'first commit not found in fzf window')

  let second_commit_line = search('second commit', 'w')
  call assert_notequal(0, second_commit_line, 'second commit not found in fzf window')

  call feedkeys("first\<cr>", 't')
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

  call timer_start(50, funcref('CheckAfterStartup'))
  call feedkeys(',gl', 'tx!')

  " Resumes after the commit "first" was chosen interactively
  call assert_equal(0, wait(10000, "&buftype != 'terminal'"), 'failed to wait for return from fzf')

  " Pull up the commit for this tree
  norm C

  let commit_description_line = search('first commit', 'w')

  call assert_notequal(&buftype, 'terminal', 'expected to exit fzf')
  call assert_notequal(0, commit_description_line, 'expected to find commit in buffer')
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
  call WaitForFzfResults(1)

  let first_commit_line = search('first commit', 'w')
  call assert_notequal(0, first_commit_line, 'first commit not found in fzf window')

  let first_commit_line = search('second commit', 'w')
  call assert_equal(0, first_commit_line, 'second commit found in fzf window, despite viewing history _before_ this commit')

  let unrelated_commit_line = search('unrelated', 'w')
  call assert_equal(0, unrelated_commit_line, 'unrelated commit found in fzf window, despite viewing history of specific file')

  call feedkeys("\<esc>")
endfunction

function TestFileInPast()
  call CdTestDir()

  call system(['git', 'init'])
  call writefile(['teststuff'], 'othertestfile.log')
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

  call timer_start(50, funcref('CheckFileInPast'))
  call feedkeys(',gl', 'tx!')
endfunction

function CheckFileChangingName(id)
  call WaitForFzfResults(2)

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

  call timer_start(50, funcref('CheckFileChangingName'))
  call feedkeys(',gl', 'tx!')
endfunction

function CheckOnFugitiveStatus(id)
  call WaitForFzfResults(1)

  let init_commit_line = search('init commit', 'w')
  call assert_notequal(0, init_commit_line, 'init commit not found in fzf window')

  call feedkeys("\<esc>")
endfunction

function TestOnFugitiveStatus()
  call CdTestDir()

  call system(['git', 'init'])
  call writefile(['teststuff'], 'testfile.log')
  call system(['git', 'add', 'testfile.log'])
  call system(['git', 'commit', '-m', 'init commit'])

  Git

  call timer_start(50, funcref('CheckOnFugitiveStatus'))
  call feedkeys(',gl', 'tx!')
endfunction

function CheckMultipleSelection(id)
  call WaitForFzfResults(2)

  call feedkeys("\<tab>\<c-k>\<tab>\<cr>", 't')
endfunction

function TestMultipleSelection()
  call CdTestDir()

  call system(['git', 'init'])
  call writefile(['something'], 'testfile.log')
  call system(['git', 'add', 'testfile.log'])
  call system(['git', 'commit', '-m', 'first commit'])
  call writefile(['something', 'something2'], 'testfile.log')
  call system(['git', 'add', 'testfile.log'])
  call system(['git', 'commit', '-m', 'second commit'])


  call timer_start(50, funcref('CheckMultipleSelection'))
  call feedkeys(',gl', 'tx!')

  " Resumes after the commit "first" was chosen interactively
  call assert_equal(0, wait(10000, "&buftype != 'terminal'"), 'failed to wait for return from fzf')

  let qf_list = getqflist()

  call assert_equal(2, len(qf_list), 'Too few quickfix list items')

  let first_bufnr = qf_list[0].bufnr
  let second_bufnr = qf_list[1].bufnr

  call assert_notequal(first_bufnr, second_bufnr, 'Expected two distinct buffers in quickfix list')

  let first_text = qf_list[0].text
  call assert_true(qf_list[0].text =~# 'second commit', 'first item should represent second commit')
  call assert_true(qf_list[1].text =~# 'first commit', 'second item should represent first commit')
endfunction

function Test()
  lua test_it()

  call TestAfterStartup()
  call TestNonGitDir()
  call TestFileInPast()
  call TestFileChangingName()
  call TestOnFugitiveStatus()

  call CleanUpDirs()

  if len(v:errors) != 0
    echoerr v:errors
    cquit!
  endif

  qall!
endfunction

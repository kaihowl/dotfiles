lua <<EOF
function expect_eq(expected, actual)
  if expected ~= actual then
    vim.notify("Expected: " .. tostring(expected) .. " actual: " .. tostring(actual), vim.log.levels.ERROR)
  end
  assert(expected == actual)
end

function test_parsing()
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

function! Test_LuaParsing()
  lua test_parsing()
endfunction

let g:test_dirs = []

function CheckScreen(pattern)
  " Needed to force display of preview in fzf
  redraw
  let res = search(a:pattern, 'w')
  " TODO(hoewelmk) add logging output when pattern fails to be found
  if res != 0
    echom 'Found pattern ' . a:pattern . ' on this line "' . getline(res) . '"'
  endif
  " TODO(hoewelmk) cleanup
  call writefile(['waiting for ' . a:pattern ], "/tmp/log.file" , 'a')
  call writefile(getline('^', '$'), "/tmp/log.file" , 'a')
  return res != 0
endfunction

function WaitForScreenContent(pattern)
  call assert_equal(0, wait(10000, function('CheckScreen', [a:pattern])), 'Failed to wait for pattern "' . a:pattern . '"')
endfunction

function WaitForTerminalContent(pattern)
  call assert_equal(0, wait(10000, '&buftype == "terminal"'), 'Failed to open fzf / terminal')
  call WaitForScreenContent(a:pattern)
endfunction

function WaitForFzfResults(num_results)
  call WaitForTerminalContent('> .* < ' . a:num_results . '/')
  " TODO(hoewelmk) clean up
  echom getline('^', '$')
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

let g:done = v:false

function CheckAfterStartup(id)
  call WaitForFzfResults(2)

  let first_commit_line = search('first commit', 'w')
  call assert_notequal(0, first_commit_line, 'first commit not found in fzf window')

  let second_commit_line = search('second commit', 'w')
  call assert_notequal(0, second_commit_line, 'second commit not found in fzf window')

  echom 'feeding keys'
  echom 'mode: ' . mode() . '\n'
  call feedkeys('ifirst', 't')

  call WaitForScreenContent('> .*first')

  call feedkeys("\<cr>", 't')

  let g:done = v:true
endfunction

function Test_This_AfterStartup()
  call CdTestDir()

  call system(['git', 'init'])
  call writefile(['something'], 'testfile.log')
  call system(['git', 'add', 'testfile.log'])
  call system(['git', 'commit', '-m', 'first commit'])
  call writefile(['something', 'something2'], 'testfile.log')
  call system(['git', 'add', 'testfile.log'])
  call system(['git', 'commit', '-m', 'second commit'])

  echom 'before mode ' . mode('"full"') . "\n"

  " call timer_start(50, funcref('CheckAfterStartup'))
  call feedkeys(',gl', 'tx')

  echom 'begin mode ' . mode('"full"') . "\n"

  redraw
  sleep 1

  echom 'waiting'
  call WaitForFzfResults(2)

  let first_commit_line = search('first commit', 'w')
  call assert_notequal(0, first_commit_line, 'first commit not found in fzf window')

  let second_commit_line = search('second commit', 'w')
  call assert_notequal(0, second_commit_line, 'second commit not found in fzf window')

  echom 'feeding keys'
  echom 'mode: ' . mode('"full"') . '\n'
  echom 'buftype: ' . &buftype . '\n'
  call feedkeys('ifirst', 't')
  call feedkeys('','x')

  call WaitForScreenContent('> .*first')

  call feedkeys("\<cr>", 't')

  let g:done = v:true

  " Resumes after the commit "first" was chosen interactively
  call assert_equal(0, wait(10000, "g:done"), 'failed to wait for return from fzf')
  call assert_equal(0, wait(10000, "&buftype != 'terminal'"), 'failed to wait for return from fzf')

  echom 'continue stuff'

  " Pull up the commit for this tree
  norm C

  call WaitForScreenContent('committer')

  let commit_description_line = search('first commit', 'w')

  call assert_notequal(&buftype, 'terminal', 'expected to exit fzf')
  call assert_notequal(0, commit_description_line, 'expected to find commit in buffer')
endfunction

function Test_NonGitDir()
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

function Test_FileInPast()
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

function Test_FileChangingName()
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

function Test_OnFugitiveStatus()
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

function Test_MultipleSelection()
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

function CheckSingleCommitPreview(id)
  call WaitForFzfResults(1)

  let init_commit_line = search('first commit', 'w')
  call assert_notequal(0, init_commit_line, 'init commit not found in fzf window')

  call WaitForTerminalContent('Author: \|bad revision')

  let failed_preview_line = search('fatal', 'w')

  call assert_equal(0, failed_preview_line, 'preview for single commit without parent should not fail')

  call feedkeys("\<esc>")
endfunction

" Feature broken, test passing...
function Test_SingleCommitPreview()
  call CdTestDir()

  call system(['git', 'init'])
  call writefile(['something'], 'testfile.log')
  call system(['git', 'add', 'testfile.log'])
  call system(['git', 'commit', '-m', 'first commit'])

  call timer_start(50, funcref('CheckSingleCommitPreview'))
  call feedkeys(',gl', 'tx!')
endfunction

function Test()
  " Source https://vimways.org/2019/a-test-to-attest-to/
  let tests = split(substitute(execute('function /^Test_This_'),
                            \  'function \(\k*()\)',
                            \  '\1',
                            \  'g'))

  for test_function in tests
    %bwipe!

    echom 'Testing ' . test_function

    execute 'call ' . test_function
  endfor

  call CleanUpDirs()

  if len(v:errors) != 0
    echoerr v:errors
    cquit!
  endif

  qall!
endfunction

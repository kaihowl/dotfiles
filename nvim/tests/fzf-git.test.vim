lua <<EOF
function expect_eq(expected, actual)
  if expected ~= actual then
    vim.notify("Expected: " .. tostring(expected) .. " actual: " .. tostring(actual), vim.log.levels.ERROR)
  end
  assert(expected == actual)
end

function test_parsing()
  local from, to = parse_renamecopy_line(" rename somefile.txt => someother.txt (100%)")
  expect_eq(from, "somefile.txt")
  expect_eq(to, "someother.txt")

  local from, to = parse_renamecopy_line(" copy somefile.txt => someother.txt (100%)")
  expect_eq(from, "somefile.txt")
  expect_eq(to, "someother.txt")

  local from, to = parse_renamecopy_line(" rename {gdb => gdb2}/somefile.txt (90%)")
  expect_eq(from, "gdb/somefile.txt")
  expect_eq(to, "gdb2/somefile.txt")

  local from, to = parse_renamecopy_line(" copy {gdb => gdb2}/somefile.txt (90%)")
  expect_eq(from, "gdb/somefile.txt")
  expect_eq(to, "gdb2/somefile.txt")

  local from, to = parse_renamecopy_line(" rename prefix/{gdb => gdb2}/somefile.txt (20%)")
  expect_eq(from, "prefix/gdb/somefile.txt")
  expect_eq(to, "prefix/gdb2/somefile.txt")

  local from, to = parse_renamecopy_line(" copy prefix/{gdb => gdb2}/somefile.txt (20%)")
  expect_eq(from, "prefix/gdb/somefile.txt")
  expect_eq(to, "prefix/gdb2/somefile.txt")

  local from, to = parse_renamecopy_line(" rename prefix/{gdb.txt => gdb2.vim} (100%)")
  expect_eq(from, "prefix/gdb.txt")
  expect_eq(to, "prefix/gdb2.vim")

  local from, to = parse_renamecopy_line(" copy prefix/{gdb.txt => gdb2.vim} (100%)")
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
  return search(a:pattern, 'w') != 0
endfunction

function WaitForScreenContent(pattern)
  call assert_equal(0, wait(10000, function('CheckScreen', [a:pattern])), 'Failed to wait for pattern "' . a:pattern . "\", screen content:\n" . join(getline('&', '$'), "\n"))
endfunction

function WaitForTerminalContent(pattern)
  call assert_equal(0, wait(10000, '&buftype == "terminal"'), 'Failed to open fzf / terminal')
  call WaitForScreenContent(a:pattern)
endfunction

function WaitForFzfResults(num_results)
  call WaitForTerminalContent(' < ' . a:num_results . '/')
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

function RunSystemCommand(cmd)
  let output = system(a:cmd)
  call assert_equal(0, v:shell_error, output)
endfunction

function AfterStartup_CheckSelectedCommit(id)
  call assert_equal(0, wait(10000, "&buftype != 'terminal'"), 'failed to wait for return from fzf')

  " Pull up the commit for this tree
  call feedkeys('C', 'tx')

  call WaitForScreenContent('committer')

  let commit_description_line = search('first commit', 'w')

  call assert_notequal(&buftype, 'terminal', 'expected to exit fzf')
  call assert_notequal(0, commit_description_line, 'expected to find commit in buffer')
  let g:done = v:true
endfunction

function Check_AfterStartup(id)
  call WaitForFzfResults(2)

  let first_commit_line = search('first commit', 'w')
  call assert_notequal(0, first_commit_line, 'first commit not found in fzf window')

  let second_commit_line = search('second commit', 'w')
  call assert_notequal(0, second_commit_line, 'second commit not found in fzf window')

  call nvim_input('ifirst<cr>')
endfunction

function Test_AfterStartup()
  call CdTestDir()

  call RunSystemCommand(['git', 'init'])
  call writefile(['something'], 'testfile.log')
  call RunSystemCommand(['git', 'add', 'testfile.log'])
  call RunSystemCommand(['git', 'commit', '-m', 'first commit', '--no-verify', '--no-gpg-sign'])
  call writefile(['something', 'something2'], 'testfile.log')
  call RunSystemCommand(['git', 'add', 'testfile.log'])
  call RunSystemCommand(['git', 'commit', '-m', 'second commit', '--no-verify', '--no-gpg-sign'])

  call timer_start(50, funcref('Check_AfterStartup'))
  call feedkeys(',gl', 'tx!')
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

  let second_commit_line = search('second commit', 'w')
  call assert_equal(0, second_commit_line, 'second commit found in fzf window, despite viewing history _before_ this commit')

  let unrelated_commit_line = search('unrelated', 'w')
  call assert_equal(0, unrelated_commit_line, 'unrelated commit found in fzf window, despite viewing history of specific file')

  call feedkeys("\<esc>")
endfunction

function Test_FileInPast()
  call CdTestDir()

  call RunSystemCommand(['git', 'init'])
  call writefile(['teststuff'], 'othertestfile.log')
  call RunSystemCommand(['git', 'add', 'othertestfile.log'])
  call RunSystemCommand(['git', 'commit', '-m', 'unrelated commit', '--no-verify', '--no-gpg-sign'])
  call writefile(['something'], 'testfile.log')
  call RunSystemCommand(['git', 'add', 'testfile.log'])
  call RunSystemCommand(['git', 'commit', '-m', 'first commit', '--no-verify', '--no-gpg-sign'])
  let file_first_commit = systemlist(['git', 'rev-parse', 'HEAD'])[0]
  call writefile(['something', 'something2'], 'testfile.log')
  call RunSystemCommand(['git', 'add', 'testfile.log'])
  call RunSystemCommand(['git', 'commit', '-m', 'second commit', '--no-verify', '--no-gpg-sign'])

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

  call nvim_input('<cr>')
endfunction

function Test_FileChangingName()
  call CdTestDir()

  call RunSystemCommand(['git', 'init'])
  call writefile(['teststuff'], 'othertestfile.log')
  call RunSystemCommand(['git', 'add', 'othertestfile.log'])
  call RunSystemCommand(['git', 'commit', '-m', 'unrelated commit', '--no-verify', '--no-gpg-sign'])
  call writefile(['something'], 'testfile.log')
  call RunSystemCommand(['git', 'add', 'testfile.log'])
  call RunSystemCommand(['git', 'commit', '-m', 'first commit', '--no-verify', '--no-gpg-sign'])
  call RunSystemCommand(['git', 'mv', 'testfile.log', 'renamedfile.log'])
  call RunSystemCommand(['git', 'commit', '-m', 'renaming commit', '--no-verify', '--no-gpg-sign'])

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

  call RunSystemCommand(['git', 'init'])
  call writefile(['teststuff'], 'testfile.log')
  call RunSystemCommand(['git', 'add', 'testfile.log'])
  call RunSystemCommand(['git', 'commit', '-m', 'init commit', '--no-verify', '--no-gpg-sign'])

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

  call RunSystemCommand(['git', 'init'])
  call writefile(['something'], 'testfile.log')
  call RunSystemCommand(['git', 'add', 'testfile.log'])
  call RunSystemCommand(['git', 'commit', '-m', 'first commit', '--no-verify', '--no-gpg-sign'])
  call writefile(['something', 'something2'], 'testfile.log')
  call RunSystemCommand(['git', 'add', 'testfile.log'])
  call RunSystemCommand(['git', 'commit', '-m', 'second commit', '--no-verify', '--no-gpg-sign'])


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

  let failed_preview_line = search('fatal:', 'w')

  call assert_equal(0, failed_preview_line, 'preview for single commit without parent should not fail')

  call feedkeys("\<esc>")
endfunction

function Test_SingleCommitPreview()
  call CdTestDir()

  " English language necessary to check for "fatal:" string
  call setenv('LC_ALL', 'en_US.UTF8')

  call RunSystemCommand(['git', 'init'])
  call assert_equal(0, writefile(['something'], 'testfile.log'))
  call RunSystemCommand(['git', 'add', 'testfile.log'])
  call RunSystemCommand(['git', 'commit', '-m', 'first commit', '--no-verify', '--no-gpg-sign'])

  call timer_start(50, funcref('CheckSingleCommitPreview'))
  call feedkeys(',gl', 'tx!')
endfunction

function RestoreCursorPos_Validate(id)
  call assert_equal(0, wait(10000, "&buftype != 'terminal'"), 'failed to wait for return from fzf')

  let cursor = getpos('.')
  call assert_equal(2, cursor[1], 'Expected to restore the line position') 
  call assert_equal(4, cursor[2], 'Expected to restore the cursor position') 

  let g:done = v:true
endfunction

function RestoreCursorPos_HitEnter(id)
  call timer_start(50, funcref('RestoreCursorPos_Validate'))
  call nvim_input('i<cr>')
endfunction

function Test_RestoreCursorPos()
  let g:done = v:false

  call CdTestDir()

  call RunSystemCommand(['git', 'init'])
  call assert_equal(0, writefile(['line1', 'line2', 'line3'], 'testfile.log'))
  call RunSystemCommand(['git', 'add', 'testfile.log'])
  call RunSystemCommand(['git', 'commit', '-m', 'first commit', '--no-verify', '--no-gpg-sign'])

  edit testfile.log
  call cursor(2, 4)

  call feedkeys(',gl', 'tx')

  call WaitForFzfResults(1)

  let first_commit_line = search('first commit', 'w')
  call assert_notequal(0, first_commit_line, 'first commit not found in fzf window')

  call timer_start(50, funcref('RestoreCursorPos_HitEnter'))
  call nvim_feedkeys('i', 'tx!', v:false)
  call assert_equal(0, wait(10000, 'g:done'), 'failed to wait for return from fzf')
endfunction

function Check_VisualSelection(id)
  call WaitForFzfResults(2)

  let first_commit_line = search('first commit', 'w')
  call assert_notequal(0, first_commit_line, 'first commit should have been found for line selection')
  let second_commit_line = search('second commit', 'w')
  call assert_equal(0, second_commit_line, 'second commit should not have been found for line selection')
  let third_commit_line = search('third commit', 'w')
  call assert_notequal(0, third_commit_line, 'third commit should have been found for line selection')

  call nvim_input('<esc>')
endfunction

function Test_VisualSelection()
  call CdTestDir()

  call RunSystemCommand(['git', 'init'])
  call assert_equal(0, writefile(['line1', 'line2', 'line3'], 'testfile.log'))
  call RunSystemCommand(['git', 'add', 'testfile.log'])
  call RunSystemCommand(['git', 'commit', '-m', 'first commit', '--no-verify', '--no-gpg-sign'])

  call assert_equal(0, writefile(['line1_changed', 'line2', 'line3'], 'testfile.log'))
  call RunSystemCommand(['git', 'add', 'testfile.log'])
  call RunSystemCommand(['git', 'commit', '-m', 'second commit', '--no-verify', '--no-gpg-sign'])

  call assert_equal(0, writefile(['line1_changed', 'line2', 'line3_changed'], 'testfile.log'))
  call RunSystemCommand(['git', 'add', 'testfile.log'])
  call RunSystemCommand(['git', 'commit', '-m', 'third commit', '--no-verify', '--no-gpg-sign'])

  edit testfile.log

  call cursor(3,1)
  norm! V

  call timer_start(50, funcref('Check_VisualSelection'))
  call feedkeys(',gl', 'tx!')
endfunction

function Check_FileNameWithSpace(id)
  call WaitForFzfResults(2)

  let first_commit_line = search('first commit', 'w')
  call assert_notequal(0, first_commit_line, 'first commit is missing')
  let second_commit_line = search('second commit', 'w')
  call assert_notequal(0, second_commit_line, 'second commit is missing')

  call WaitForScreenContent('Author:')

  let broken_preview = search('fatal:', 'w')
  call assert_equal(0, broken_preview, 'preview is broken')
  let working_preview = search('Author:', 'w')
  call assert_notequal(0, working_preview, 'did not find preview')

  call nvim_input('<esc>')
endfunction

" TODO(kaihowl) problem test case
function Test_FileNameWithSpace()
  call CdTestDir()

  call RunSystemCommand(['git', 'init'])
  call assert_equal(0, writefile(['something'], 'test file'))
  call RunSystemCommand(['git', 'add', 'test file'])
  call RunSystemCommand(['git', 'commit', '-m', 'first commit', '--no-verify', '--no-gpg-sign'])

  call assert_equal(0, writefile(['something2'], 'test file'))
  call RunSystemCommand(['git', 'add', 'test file'])
  call RunSystemCommand(['git', 'commit', '-m', 'second commit', '--no-verify', '--no-gpg-sign'])

  edit test\ file

  " English language necessary to check for "fatal:" and "Author:" strings
  call setenv('LC_ALL', 'en_US.UTF8')

  call timer_start(50, funcref('Check_FileNameWithSpace'))
  call feedkeys(',gl', 'tx!')
endfunction

function CheckTestFileNameWithLeadingDash(id)
  call WaitForFzfResults(1)

  let first_commit_line = search('first commit', 'w')
  call assert_notequal(0, first_commit_line, 'first commit is missing')

  call WaitForScreenContent('Author:')

  let broken_preview = search('fatal:', 'w')
  call assert_equal(0, broken_preview, 'preview is broken')
  let working_preview = search('Author:', 'w')
  call assert_notequal(0, working_preview, 'did not find preview')

  call nvim_input('<esc>')
endfunction

function Test_FileNameWithLeadingDash()
  call CdTestDir()

  call RunSystemCommand(['git', 'init'])
  call assert_equal(0, writefile(['something'], '-test'))
  call RunSystemCommand(['git', 'add', './-test'])
  call RunSystemCommand(['git', 'commit', '-m', 'first commit', '--no-verify', '--no-gpg-sign'])

  edit ./-test

  " English language necessary to check for "fatal:" and "Author:" strings
  call setenv('LC_ALL', 'en_US.UTF8')

  call timer_start(50, funcref('CheckTestFileNameWithLeadingDash'))
  call feedkeys(',gl', 'tx!')
endfunction

" TODO(hoewelmk) unify the "hitenter" functions?
function CopiedFileFollow_HitEnter(id)
  call nvim_input('i<cr>')
endfunction

function Test_CopiedFileFollow()
  call CdTestDir()

  call RunSystemCommand(['git', 'init'])
  call assert_equal(0, writefile(['something', 'something2', 'something3'], 'firstfile'))
  call RunSystemCommand(['git', 'add', 'firstfile'])
  call RunSystemCommand(['git', 'commit', '-m', 'first commit', '--no-verify', '--no-gpg-sign'])

  call assert_equal(0, writefile(['something', 'something2', 'something3'], 'secondfile'))
  call RunSystemCommand(['git', 'add', 'secondfile'])
  call RunSystemCommand(['git', 'commit', '-m', 'second commit', '--no-verify', '--no-gpg-sign'])

  edit secondfile

  call feedkeys(',gl', 'tx')

  call WaitForFzfResults(2)

  let first_commit_line = search('first commit', 'w')
  call assert_notequal(0, first_commit_line, 'Could not find first commit with correct (copied-from) file name')

  let second_commit_line = search('second commit', 'w')
  call assert_notequal(0, second_commit_line, 'Could not find second commit with current file name')

  call timer_start(50, funcref('CopiedFileFollow_HitEnter'))
  call nvim_feedkeys('ifirst', 'tx!', v:false)

  call assert_match('firstfile$', bufname(), 'Wrong file name (copied-from)')
endfunction

function Check_Preview(num_results, id)
  call WaitForFzfResults(a:num_results)

  call WaitForScreenContent('Author:\|fatal:')

  let broken_preview = search('fatal:', 'w')
  call assert_equal(0, broken_preview, 'preview is broken')
  let working_preview = search('Author:', 'w')
  call assert_notequal(0, working_preview, 'did not find preview')

  let unrecognized_line = search('unexpected summary', 'w')
  call assert_equal(0, unrecognized_line, 'missing case handling')

  call nvim_input('i<cr>')
endfunction

function Test_DifferentPwd()
  call CdTestDir()

  call RunSystemCommand(['git', 'init'])
  call assert_equal(0, writefile(['something', 'something2', 'something3'], 'firstfile'))
  call RunSystemCommand(['git', 'add', 'firstfile'])
  call RunSystemCommand(['git', 'commit', '-m', 'first commit', '--no-verify', '--no-gpg-sign'])

  edit firstfile

  " Go to different testdir than where current "firstfile" is located in
  call CdTestDir()

  " English language necessary to check for "fatal:" and "Author:" strings
  call setenv('LC_ALL', 'en_US.UTF8')

  call timer_start(50, {id -> Check_Preview(1, id)})
  call feedkeys(',gl', 'tx!')

  " Explicitly use the HEAD version of the 'firstfile'
  Gedit HEAD:%

  call timer_start(50, {id -> Check_Preview(1, id)})
  call feedkeys(',gl', 'tx!')

  " Explicitly use the staging version of the 'firstfile'
  Gedit :0:%

  call timer_start(50, {id -> Check_Preview(1, id)})
  call feedkeys(',gl', 'tx!')
endfunction

function Test_VerticalSplit()
  function Check_VerticalSplit(id)
    call WaitForFzfResults(2)
    call nvim_input('ifirst<c-v>')
  endfunction

  call CdTestDir()

  call RunSystemCommand(['git', 'init'])
  call writefile(['something'], 'testfile.log')
  call RunSystemCommand(['git', 'add', 'testfile.log'])
  call RunSystemCommand(['git', 'commit', '-m', 'first commit', '--no-verify', '--no-gpg-sign'])
  call writefile(['something', 'something2'], 'testfile.log')
  call RunSystemCommand(['git', 'add', 'testfile.log'])
  call RunSystemCommand(['git', 'commit', '-m', 'second commit', '--no-verify', '--no-gpg-sign'])

  edit testfile.log

  call timer_start(50, funcref('Check_VerticalSplit'))
  call feedkeys(',gl', 'tx!')

  " Now we should have a vertical split
  let layout = winlayout()
  call assert_equal('row', layout[0])
  call assert_equal(2, len(layout[1]))
  call assert_equal('leaf', layout[1][0][0])
  call assert_equal('leaf', layout[1][1][0])

  " Both windows should be in diff mode
  call assert_true(getwinvar(layout[1][0][1], '&diff'))
  call assert_true(getwinvar(layout[1][1][1], '&diff'))
endfunction

function Test_DeletedFile()
  call CdTestDir()

  call RunSystemCommand(['git', 'init'])
  call assert_equal(0, writefile(['something', 'something2', 'something3'], 'firstfile'))
  call RunSystemCommand(['git', 'add', 'firstfile'])
  call RunSystemCommand(['git', 'commit', '-m', 'first commit', '--no-verify', '--no-gpg-sign'])
  call RunSystemCommand(['git', 'rm', 'firstfile'])
  call RunSystemCommand(['git', 'commit', '-m', 'second commit', '--no-verify', '--no-gpg-sign'])

  call timer_start(50, {id -> Check_Preview(2, id)})
  call feedkeys(',gl', 'tx!')
endfunction

" showing commit history of a buffer should still working on the staging
" / etc. buffers that are extensions in fugitive with ":0", ":1", ":2", ":3"
" Since those are not properly integrated in fugitive as well (e.g., copying
" the commit hash with "y ctrl-g" leaves the special hashes unresolved.
" Moreover, "0" references the staging area, which by design has no hash
" associated.
function Test_SpecialCommit()
  call CdTestDir()

  call RunSystemCommand(['git', 'init'])
  call assert_equal(0, writefile(['something', 'something2', 'something3'], 'firstfile'))
  call RunSystemCommand(['git', 'add', 'firstfile'])
  call RunSystemCommand(['git', 'commit', '-m', 'first commit', '--no-verify', '--no-gpg-sign'])

  edit firstfile
  Gedit :0:%

  " English language necessary to check for "fatal:" and "Author:" strings
  call setenv('LC_ALL', 'en_US.UTF8')

  call timer_start(50, {id -> Check_Preview(1, id)})
  call feedkeys(',gl', 'tx!')
endfunction

function Check_InGitCommitMsg(id)
  call WaitForFzfResults(1)

  let first_commit_line = search('first commit', 'w')
  call assert_notequal(0, first_commit_line, 'first commit not found in fzf window')

  call nvim_input('<esc>')
endfunction

function Test_InGitCommitMsg()
  call CdTestDir()

  call RunSystemCommand(['git', 'init'])
  call writefile(['something'], 'testfile.log')
  call RunSystemCommand(['git', 'add', 'testfile.log'])
  call RunSystemCommand(['git', 'commit', '-m', 'first commit', '--no-verify', '--no-gpg-sign'])
  call writefile(['something', 'something2'], 'testfile.log')
  call RunSystemCommand(['git', 'add', 'testfile.log'])

  " Workaround for COMMIT_EDITMSG file / commit works asynchronously
  exe 'edit ' . FugitiveGitDir() . '/SPECIAL_FILE'

  call timer_start(50, funcref('Check_InGitCommitMsg'))
  call feedkeys(',gl', 'tx!')
endfunction

function Check_InGitHubFiles(id)
  call WaitForFzfResults(1)

  let first_commit_line = search('first commit', 'w')
  call assert_notequal(0, first_commit_line, 'first commit not found in fzf window')

  let second_commit_line = search('second commit', 'w')
  call assert_equal(0, second_commit_line, 'second commit found in fzf window')

  call nvim_input('<esc>')
endfunction

" The Test_InGitCommitMsg ensures that history default to the full repository
" when a file in the .git folder like the COMMIT_EDITMSG is opened.
" This test ensures that files in the .github/ folder (same prefix) are
" exempt.
function Test_InGitHubFiles()
  call CdTestDir()

  call RunSystemCommand(['git', 'init'])
  call mkdir('.github')
  call writefile(['something'], '.github/testfile.log')
  call RunSystemCommand(['git', 'add', '.github/testfile.log'])
  call RunSystemCommand(['git', 'commit', '-m', 'first commit', '--no-verify', '--no-gpg-sign'])
  call writefile(['something'], 'otherfile.log')
  call RunSystemCommand(['git', 'add', 'otherfile.log'])
  call RunSystemCommand(['git', 'commit', '-m', 'second commit', '--no-verify', '--no-gpg-sign'])

  exec 'edit .github/testfile.log'

  call timer_start(50, funcref('Check_InGitHubFiles'))
  call feedkeys(',gl', 'tx!')
endfunction

function Check_NoSortStep2(id)
  call WaitForScreenContent('commit.*<.*/')  " 'commit' entered on prompt

  let correct_order = search('commit title.*\n.*commit title with a longer word', 'w')
  call assert_notequal(0, correct_order, 'order of commits incorrect')

  call nvim_input('<esc>')
endfunction

function Check_NoSort(id)
  call WaitForFzfResults(2)

  call timer_start(50, funcref('Check_NoSortStep2'))
  call nvim_input('commit')
endfunction

function Test_NoSort()
  call CdTestDir()

  call RunSystemCommand(['git', 'init'])
  call writefile(['something'], 'firstfile')
  call RunSystemCommand(['git', 'add', 'firstfile'])
  call RunSystemCommand(['git', 'commit', '-m', 'commit title', '--no-verify', '--no-gpg-sign'])
  call writefile(['something'], 'secondfile')
  call RunSystemCommand(['git', 'add', 'secondfile'])
  call RunSystemCommand(['git', 'commit', '-m', 'commit title with a longer word', '--no-verify', '--no-gpg-sign'])

  " The second, later commit still matches the word "commit". But as the first
  " commit has has a short length the default tie breaker will sort it first.
  " Without --no-sort, the commits will be swapped in order.
  call timer_start(50, funcref('Check_NoSort'))
  call feedkeys(',gl', 'tx!')
endfunction


function Test()
  " Source https://vimways.org/2019/a-test-to-attest-to/
  let tests = split(substitute(execute('function /^Test_'),
                            \  'function \(\k*()\)',
                            \  '\1',
                            \  'g'))

  for test_function in tests
    bufdo! %bwipe!
    echom 'Testing ' . test_function

    try
      execute 'call ' . test_function
    catch
      call add( v:errors,
              \   'Uncaught exception in test: '
              \ . v:exception
              \ . ' at '
              \ . v:throwpoint )
    endtry
  endfor

  call CleanUpDirs()

  if len(v:errors) != 0
    for error in v:errors
      for line in split(error,"\n")
        echoerr line
      endfor
    endfor
    cquit!
  endif

  qall!
endfunction

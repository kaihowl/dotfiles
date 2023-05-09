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
function Test()
  lua test_it()
  if len(v:errors) != 0
    cquit!
  endif

  quit!
endfunction

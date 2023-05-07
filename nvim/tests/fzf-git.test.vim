lua <<EOF
function expect_eq(expected, actual)
  if expected ~= actual then
    vim.notify("Expected: " .. tostring(expected) .. " actual: " .. tostring(actual), vim.log.levels.ERROR)
  end
  assert(expected == actual)
end

function test_it()
  local from, to = parse_rename_line(" rename somefile.txt => someother.txt")
  expect_eq(from, "someefile.txt")
  expect_eq(to, "someother.txt")

  local from, to = parse_rename_line(" rename {gdb => gdb2}/somefile.txt")
  vim.notify("from " .. from .. " to " .. to)

  local from, to = parse_rename_line(" rename prefix/{gdb => gdb2}/somefile.txt")
  vim.notify("from " .. from .. " to " .. to)

  local from, to = parse_rename_line(" rename prefix/{gdb.txt => gdb2.vim}")
  vim.notify("from " .. from .. " to " .. to)
end
EOF
function Test()
  lua test_it()
  if len(v:errors) != 0
    cquit!
  endif

  quit!
endfunction

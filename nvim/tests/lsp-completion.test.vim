lua << EOF
function _G.has_complete_with_starting_text(text)
  vim.notify("text: " .. text)
  for key, value in pairs(require('cmp').get_entries()) do
    vim.notify(value.completion_item.label)
    if vim.startswith(vim.trim(value.completion_item.label), text) then
      vim.notify("return true")
      return true
    end
  end
  vim.notify("return false")
  return false
end

function _G.completion_callback(expected_completion)
  vim.cmd('echomsg "complete shown"')
  if has_complete_with_starting_text(expected_completion) then
    vim.cmd('echomsg "done done"')
    vim.cmd('let g:test_result = v:true')
    vim.cmd('let g:test_done = v:true')
    vim.cmd('call feedkeys("\\<esc>")')
  end
end

function _G.setup_completion_callback(expected_completion)
  require 'cmp'.event:on('menu_opened', function(...) completion_callback(expected_completion) end)
end
EOF

function ProtoTest(filename, complete_chars, expected_completion, init_timeout_seconds)
  call v:lua.setup_completion_callback(a:expected_completion)

  let g:test_result = v:false
  let g:test_done = v:false

  silent echomsg 'Running on ' . a:filename
  exec 'noswap edit! '. a:filename

  " Wait until the LSP server / client has established connection.
  let lsp_init =  wait(a:init_timeout_seconds * 1000, 'luaeval("#vim.lsp.buf_get_clients()") != 0')
  " silent echomsg 'lsp_init: ' . lsp_init
  if lsp_init != 0
    " silent echomsg 'Failed to establish LSP connection'
    for line in readfile(luaeval('vim.lsp.get_log_path()'))[-20:]
      " silent echomsg line
    endfor
    return v:false
  endif

  " Type half-baked input to trigger diagnostics, which we use to determine if the LSP server is ready.
  " E.g., rust-analyzer is connected quickly, but not ready due to indexing
  " for a while.
  call feedkeys('o'.a:complete_chars, 'tx')
  let wait_for_diagnostic =  wait(20000, 'luaeval("#vim.diagnostic.get()") != 0')
  if wait_for_diagnostic != 0
    silent echomsg 'Server was not ready in time'
    return v:false
  endif

  " Now that the server is ready, trigger a LSP completion.
  call feedkeys("A\<tab>", 'tx!')

  " We only get here once the completion handler sees the expected completion
  " and therefore leaves the insert mode.
  return g:test_done && g:test_result
endfunction

function Test()
  set cmdheight=10
  let tests = {
        \'test.cpp': {
          \'complete_chars': 'inl',
          \'expected_completion': 'inline',
          \'init_timeout_seconds': 30,
          \},
        \}
  for [filename, test_data] in items(tests)
    if !ProtoTest(filename, test_data['complete_chars'], test_data['expected_completion'], get(test_data, 'init_timeout_seconds', 20))
      echomsg 'Test failed for ' . filename
      mess
      cquit!
    else
      echomsg 'Test successful for ' . filename
    endif
  endfor
  qall!
endfunction

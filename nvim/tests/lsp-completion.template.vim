" This file contains the harness for testing LSP in various langauges.
" To maintain a clean environment, we spawn a complete new nvim instance and
" source this harness instead of running multiple tests in the same nvim
" instance. This is easier as for example the global completion_callback would
" otherwise be appended for all tests with no supported way to reset
" / unregister them.
"
" Overview:
" - Open a non-existing file in the target language. For workspace-oriented
"   langues, open an existing file in a committed, ready-made workspace.
" - Insert the first few characters of a completion that can only be emitted
"   by LSP.
" - As some language servers are not immediately ready after establishing
"   a connection, wait for the diagnostics to appear that flag the
"   half-inserted completion.
" - Evoke a completion by pressing tab and stay in insert mode
" - Once, the desired completion appears in the list of all completions, exit
"   insert mode and declare success.

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
  vim.notify('complete shown')
  vim.notify('expected_completion: ' .. expected_completion)
  if has_complete_with_starting_text(expected_completion) then
    vim.notify('done done')
    vim.cmd('let g:test_result = v:true')
    vim.cmd('let g:test_done = v:true')
    vim.cmd('call feedkeys("\\<esc>")')
  end
end

function _G.setup_completion_callback(expected_completion)
  require 'cmp'.event:on('menu_opened', function(...) completion_callback(expected_completion) end)
end
EOF

function ProtoTest(filename, complete_chars, expected_completion)
  echomsg 'Setting up handler'
  call v:lua.setup_completion_callback(a:expected_completion)
  echomsg 'Done setting up handler'

  lua vim.lsp.set_log_level("debug")

  let g:test_result = v:false
  let g:test_done = v:false

  echomsg 'Running on ' . a:filename
  exec 'noswap edit! '. a:filename

  " Wait until the LSP server / client has established connection.
  let lsp_init =  wait(30 * 1000, 'luaeval("#vim.lsp.buf_get_clients()") != 0')
  echomsg 'lsp_init: ' . lsp_init
  if lsp_init != 0
    echomsg 'Failed to establish LSP connection'
    for line in readfile(luaeval('vim.lsp.get_log_path()'))[-20:]
      echomsg line
    endfor
    return v:false
  endif

  " Type half-baked input to trigger diagnostics, which we use to determine if the LSP server is ready.
  " E.g., rust-analyzer is connected quickly, but not ready due to indexing
  " for a while.
  echomsg 'About to feed keys'
  call feedkeys('o'.a:complete_chars, 'tx')
  echomsg 'Fed keys, waiting'
  let wait_for_diagnostic =  wait(30 * 1000, 'luaeval("#vim.diagnostic.get()") != 0')
  if wait_for_diagnostic != 0
    echomsg 'Server was not ready in time'
    return v:false
  endif

  " Now that the server is ready, trigger a LSP completion.
  call feedkeys("A\<tab>", 'tx!')

  " We only get here once the completion handler sees the expected completion
  " and therefore leaves the insert mode.
  return g:test_done && g:test_result
endfunction

function FullTest(filename, complete_chars, expected_completion)
  if !ProtoTest(a:filename, a:complete_chars, a:expected_completion)
    echomsg 'Test failed for ' . a:filename
    mess
    cquit!
  else
    echomsg 'Test successful for ' . a:filename
  endif
  qall!
endfunction


lua << EOF
function _G.has_complete_with_starting_text(text)
  vim.cmd("echomsg 'hello'")
  vim.cmd('call feedkeys("\\<esc>i\\<tab>")')
  vim.cmd("redraw!")
  for key, value in pairs(require('cmp').get_entries()) do
    if vim.startswith(value.completion_item.label, text) then
      return true
    end
  end
  return false
end
EOF

" Test completion with omni-complete and LSP
function Check(id)
  " TODO(kaihowl) make expectation configurable
  let has_desired_completion = wait(1000, "luaeval('has_complete_with_starting_text(_A)', 'writeln!')")
  echomsg 'has_desired_completion: ' . has_desired_completion
  if has_desired_completion == 0
    silent echomsg 'Setting test result'
    redraw!
    let g:test_result = v:true
    silent echomsg 'Setting test state'
  endif
  " Make sure that all pending feedkeys are ended
  call feedkeys("\<esc>")
  let g:test_done = v:true
endfunction

function FeedIt(complete_chars)
  call timer_start(500, funcref('Check'))
  echomsg 'Feeding keys'
  " silent echomsg 'Feeding keys'
  redraw!
  " Get completion for a unique word that can only be sourced from LSP
  " call feedkeys('O'.a:complete_chars, 'tx!')
  call feedkeys('O'.a:complete_chars."\<c-x>\<c-o>", 'tx!')
endfunction

function ProtoTest(filename, complete_chars, init_timeout_seconds)
  let g:test_result = v:false
  let g:test_done = v:false

  " silent echomsg 'Running on ' . a:filename
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

  " Make sure the function returns and does not wait for the end of the insert
  " mode instead
  call timer_start(50, {-> execute('call FeedIt("'.a:complete_chars.'")')})
  " silent echomsg 'Starting to wait'
  let test_wait = wait(20000, 'g:test_done')
  " silent echomsg 'test_wait: ' . test_wait
  return g:test_result
endfunction

function Test()
  set cmdheight=10
  let tests = {
        \'test-rustanalyzer/src/main.rs': {
          \'complete_chars': 'write',
          \'init_timeout_seconds': 30,
          \},
        \}
  for [filename, test_data] in items(tests)
    if !ProtoTest(filename, test_data['complete_chars'], get(test_data, 'init_timeout_seconds', 20))
      echomsg 'Test failed for ' . filename
      mess
    else
      echomsg 'Test successful for ' . filename
    endif
  endfor
endfunction

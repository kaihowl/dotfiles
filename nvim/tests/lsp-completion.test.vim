" Test completion with omni-complete and LSP
function Check(id)
  " Wait until the completion menu is visible.
  echomsg 'Waiting for completion to show'
  let complete_visible = wait(10000, "complete_info()['pum_visible']")
  echomsg 'complete_visible: ' . complete_visible
  let last_complete_info = complete_info()
  if len(last_complete_info['items']) > 0
    echomsg 'Setting test result'
    let g:test_result = v:true
  endif
  echomsg 'Setting test state'
  let g:test_done = v:true
  " Make sure that all pending feedkeys are ended
  call feedkeys("\<esc>")
endfunction

function FeedIt(complete_chars)
  call timer_start(500, funcref('Check'))
  echomsg 'Feeding keys'
  " Get completion for 'inline' keyword
  call feedkeys('i'.a:complete_chars."\<c-x>\<c-o>", 'tx!')
endfunction

function ProtoTest(filename, complete_chars)
  let g:test_result = v:false
  let g:test_done = v:false

  echomsg 'Running on ' . a:filename
  exec 'noswap edit! '. a:filename

  " Wait until the LSP server / client has established connection.
  let lsp_init =  wait(20000, 'luaeval("#vim.lsp.buf_get_clients()") != 0')
  echomsg 'lsp_init: ' . lsp_init
  if lsp_init != 0
    echomsg 'Failed to establish LSP connection'
    for line in readfile(luaeval('vim.lsp.get_log_path()'))[-20:]
      echomsg line
    endfor
    return v:false
  endif

  " Make sure the function returns and does not wait for the end of the insert
  " mode instead
  call timer_start(50, {-> execute('call FeedIt("'.a:complete_chars.'")')})
  echomsg 'Starting to wait'
  let test_wait = wait(20000, 'g:test_done')
  echomsg 'test_wait: ' . test_wait
  return g:test_result
endfunction

function Test()
  let tests = {
        \'test12.cpp': {'complete_chars': 'inl'},
        \'test12.py': {'complete_chars': 'imp'},
        \}
  for [filename, test_data] in items(tests)
    if !ProtoTest(filename, test_data['complete_chars'])
      echoerr 'Test failed for ' . filename
      mess
      cquit!
    else
      echomsg 'Test successful for ' . filename
    endif
  endfor
  qall!
endfunction

" Test completion with omni-complete and LSP
function Check(id)
  " Wait until the completion menu is visible.
  redraw
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


function Trigger(id)
  call timer_start(500, funcref('Check'))
  call feedkeys("\<c-x>\<c-o>")
endfunction

function FeedIt(complete_chars)
  call timer_start(500, funcref('Trigger'))
  echomsg 'Feeding keys'
  " Get completion for 'inline' keyword
  call feedkeys('i'.a:complete_chars, 'tx!')
endfunction

function ProtoTest(filename, complete_chars)
  let g:test_result = v:false
  let g:test_done = v:false

  echomsg 'Running on ' . a:filename
  exec 'noswap edit! '. a:filename

  " Wait until the LSP server / client has established connection.
  let lsp_init =  wait(10000, 'luaeval("#vim.lsp.buf_get_clients()") != 0')
  echomsg 'lsp_init: ' . lsp_init

  " Make sure the function returns and does not wait for the end of the insert
  " mode instead
  call timer_start(50, {-> execute('call FeedIt("'.a:complete_chars.'")')})
  echomsg 'Starting to wait'
  call wait(10000, 'g:test_done')
  return g:test_result
endfunction

function Test()
  let tests = {
        \'test12.cpp': 'inl',
        \'test12.py': 'imp',
        \}
  for [filename, complete_chars] in items(tests)
    if !ProtoTest(filename, complete_chars)
      echoerr 'Test failed for ' . filename
      mess
      cquit!
    else
      echomsg 'Test successful for ' . filename
    endif
  endfor
  qall!
endfunction

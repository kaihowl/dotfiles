lua << EOF
function _G.has_complete_with_starting_text(text)
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
  let has_desired_completion = wait(2000, "luaeval('has_complete_with_starting_text(_A)', 'writeln!')")
  silent echoerr 'has_desired_completion: ' . has_desired_completion
  " Make sure that all pending feedkeys are ended
  call feedkeys("\<esc>", 't')
  if has_desired_completion == 0
    silent echoerr 'Setting test result'
    let g:test_result = v:true
    silent echoerr 'Setting test state'
    let g:test_done = v:true
  else
    " silent echoerr 'rerun'
    call timer_start(1000, funcref('Check'))
    call feedkeys("A \<bs>", 'tx!')
  endif
endfunction

function FeedIt(complete_chars)
  call timer_start(500, funcref('Check'))
  silent echoerr 'Feeding keys'
  " Get completion for a unique word that can only be sourced from LSP
  " call feedkeys('O'.a:complete_chars, 'tx!')
  call feedkeys('O'.a:complete_chars."\<c-x>\<c-o>", 'tx!')
endfunction

function ProtoTest(filename, complete_chars, init_timeout_seconds)
  let g:test_result = v:false
  let g:test_done = v:false

  " silent echoerr 'Running on ' . a:filename
  exec 'noswap edit! '. a:filename

  " Wait until the LSP server / client has established connection.
  let lsp_init =  wait(a:init_timeout_seconds * 1000, 'luaeval("#vim.lsp.buf_get_clients()") != 0')
  " silent echoerr 'lsp_init: ' . lsp_init
  if lsp_init != 0
    " silent echoerr 'Failed to establish LSP connection'
    for line in readfile(luaeval('vim.lsp.get_log_path()'))[-20:]
      " silent echoerr line
    endfor
    return v:false
  endif

  " Make sure the function returns and does not wait for the end of the insert
  " mode instead
  call timer_start(50, {-> execute('call FeedIt("'.a:complete_chars.'")')})
  " silent echoerr 'Starting to wait'
  let test_wait = wait(20000, 'g:test_done')
  " silent echoerr 'test_wait: ' . test_wait
  return g:test_result
endfunction

function Test()
  let tests = {
        \'test-rustanalyzer/src/main.rs': {
          \'complete_chars': 'write',
          \'init_timeout_seconds': 30,
          \},
        \}
  for [filename, test_data] in items(tests)
    if !ProtoTest(filename, test_data['complete_chars'], get(test_data, 'init_timeout_seconds', 20))
      echoerr 'Test failed for ' . filename
      mess
    else
      echomsg 'Test successful for ' . filename
    endif
  endfor
endfunction

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
  silent! redraw!
  call wait(1000, "luaeval('require(\"cmp\").visible()')")
  let has_desired_completion = luaeval('has_complete_with_starting_text(_A)', 'writeln!')
  echomsg 'has_desired_completion: ' . has_desired_completion
  if has_desired_completion == v:true
    silent echomsg 'Setting test result'
    redraw!
    let g:test_result = v:true
      silent echomsg 'Setting test state'
    " Make sure that all pending feedkeys are ended
    call feedkeys("\<esc>")
    let g:test_done = v:true
  else
    echomsg 'Retrying'
    call timer_start(1000, funcref('Check'))
    call feedkeys("\<tab>", 'tx!')
  endif
endfunction

function Redraw(id)
  silent! redraw!
  call feedkeys("\<esc>")
  call timer_start(500, funcref('Redraw'))
  call feedkeys("i\<tab>", 'tx!')
endfunction

function FeedIt(complete_chars)
  echomsg 'Feeding keys'
  silent! redraw!
  " call timer_start(500, funcref('Check'))
  call timer_start(500, funcref('Redraw'))
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
  " echomsg 'Starting to wait'
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

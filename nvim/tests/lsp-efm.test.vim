" Test diagnostics inserted via efm lsp
function Check(filename)
  execute 'noswap edit! test-efm/' . a:filename
  " Wait until the LSP server / client has established connection.
  let lsp_init =  wait(10000, 'luaeval("#vim.lsp.buf_get_clients()") != 0')
  echomsg 'lsp_init: ' . lsp_init

  let wait_for_diagnostic =  wait(10000, 'luaeval("#vim.diagnostic.get()") != 0')

  echomsg 'wait_for_diagnostic: ' . wait_for_diagnostic

  if luaeval('#vim.diagnostic.get()') == 0
    echomsg 'Expected diagnostics for bash'
    for line in readfile(luaeval('vim.lsp.get_log_path()'))[-20:]
      echomsg line
    endfor
    return v:false
  endif
  return v:true
endfunction

function Test()
  let tests = ['testscript.sh', 'testscript.zsh']
  for t in tests
    if ! Check(t)
      echoerr 'Failed test ' . t
      cquit!
    else
      echomsg 'Successful test ' . t
    endif
  endfor
  qall!
endfunction

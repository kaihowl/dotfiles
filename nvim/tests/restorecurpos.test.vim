function Test()
  let v:errmsg = ''
  RestoreCurPos echom('test')
  if !empty(v:errmsg)
    cquit!
  endif

  let v:errmsg = ''
  Silent echom('test')
  if !empty(v:errmsg)
    cquit!
  endif
  "All well
  quitall!
endfunction

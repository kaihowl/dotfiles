let g:done = v:false
function SecondCheck(id)
  echom 'called me'
  call feedkeys("\<cr>", 't')
endfunction

function CheckAfterStartup(id)
  sleep 1
  " call timer_start(1000, funcref('SecondCheck'))
  call feedkeys("ifirst\<cr>", 't')
  let g:done = v:true
endfunction

call timer_start(50, funcref('CheckAfterStartup'))
call feedkeys(',gl', 'tx')

call wait(10000, 'g:done')


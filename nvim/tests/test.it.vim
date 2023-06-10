let g:done = v:false

" call timer_start(50, funcref('CheckAfterStartup'))
call feedkeys(',gl', 'tx')
sleep 1
" call timer_start(1000, funcref('SecondCheck'))
call feedkeys("ifirst\<cr>", 't')

let g:done = v:true

call wait(10000, 'g:done')


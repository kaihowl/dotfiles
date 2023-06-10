let g:done = v:false

" call timer_start(50, funcref('CheckAfterStartup'))
echom 'TODO(hoewelmk) mode 1: ' . mode('"full"')
call feedkeys(',gl', 'tx')
echom 'TODO(hoewelmk) mode 2: ' . mode('"full"')

redraw
sleep 1
" call timer_start(1000, funcref('SecondCheck'))
call feedkeys("ifirst\<cr>", 't')
echom 'mode 3: ' . mode('"full"')

let g:done = v:true

call wait(10000, 'g:done')

echom 'mode 4: ' . mode('"full"')

quitall!

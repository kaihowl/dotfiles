:Rg "\. <<"
:call feedkeys("\<cr>", 't')
:"check correct line
:if getcurpos()[1] != 2
:  cquit!
:endif
:"check correct column
:if getcurpos()[2] != 29
:  cquit!
:endif
:"All well
:quitall!


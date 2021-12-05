:Rg \. <<
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
:"Test space separated searches, i.e., multi word
:Rg of the
:cfirst
:if getcurpos()[1] != 4
:  cquit!
:endif
:"check correct column
:if getcurpos()[2] != 22
:  cquit!
:endif
:quitall!


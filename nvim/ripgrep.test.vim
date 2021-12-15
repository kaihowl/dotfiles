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
:"check correct line
:if getcurpos()[1] != 4
:  cquit!
:endif
:"check correct column
:if getcurpos()[2] != 22
:  cquit!
:endif
:"Test passing parameters to the bang version of the command
:"Should not find 'foolish' but only 'fool' when asked for a full word match with '-w'
:Rg! -w fool
:cfirst
:"check correct line
:if getcurpos()[1] != 6
:  cquit!
:endif
:"check correct column
:if getcurpos()[2] != 7
:  cquit!
:endif
:Rg #
:cfirst
:"check correct line
:if getcurpos()[1] != 7
:  cquit!
:endif
:"check correct column
:if getcurpos()[2] != 11
:  cquit!
:endif
:quitall!

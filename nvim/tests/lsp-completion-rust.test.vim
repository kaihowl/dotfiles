source lsp-completion.template.vim

function Test()
  call FullTest('test-rustanalyzer/src/main.rs', 'writ', 'writeln')
endfunction

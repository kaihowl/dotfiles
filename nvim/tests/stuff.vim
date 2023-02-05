lua << EOF
function _G.print_me()
  for key, value in pairs(require('cmp').get_entries()) do
    if vim.startswith(value.completion_item.label, "writeln!") then
      print("Gotcha!")
    end
  end
  -- print(vim.inspect(vim.tbl_keys(require('cmp').get_entries())))
end
EOF

function Log_pum_visible(id)
  set cmdheight=10
  set showmode
  silent echoerr 'pum_visible ' . get(complete_info(), 'pum_visible', 'default')
  silent echoerr 'cmp.visible ' . luaeval("require('cmp').visible()")
  " echom 'iterms ' . string(get(complete_info(), 'items', []))
  " echom 'pumvisible ' . pumvisible()
  " silent let stuff = luaeval("vim.inspect(vim.tbl_keys(require('cmp').get_entries()[0]))")
  " print(vim.inspect(vim.tbl_key(require('cmp').get_entries())))
  " echom 'cmp_get_entries ' . stuff
  lua print_me()
  call timer_start(1000, funcref('Log_pum_visible'))
endfunction

call Log_pum_visible(1)

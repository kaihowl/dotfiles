-- Call on
--   - file
--   - file with commit in past
--   - dir
--   - dir with commit in past
--   - file in non git working directory
--   - terminal buffer with cwd is git
--   - terminal buffer with cwd is not git
function commit_and_path()
  local fugitive_path = vim.fn.FugitiveFind()
  local parsed = vim.fn.FugitiveParse(fugitive_path)
  if parsed[1] ~= '' then
    return vim.fn.split(parsed[1], ':')
  else
    return {"HEAD", fugitive_path}
  end
end

function make_git_log_command(commit_and_path)
  return vim.fn.FugitiveShellCommand({
    'log',
    '--color',
    '--pretty=format:%C(yellow)%h%Creset %C(green)(%cr)%Creset %s %C(blue)<%an>%Creset',
    '--follow',
    commit_and_path[1],
    '--',
    commit_and_path[2]
  })
end

function git_log_buf()
  return make_git_log_command(commit_and_path())
end

require'fzf-lua'.fzf_exec(git_log_buf(), {actions={
  ['default'] = function(selected, opts)
    vim.notify(vim.inspect(selected) .. " " .. vim.inspect(opts))
  end
}})

-- Call on
--   - file
--   - file with commit in past
--   - dir
--   - dir with commit in past
--   - file in non git working directory
--   - terminal buffer with cwd is git
--   - terminal buffer with cwd is not git
--   - with file changing its filename in the --follow output
--   - single output line
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
    '--pretty=tformat:%C(yellow)%h%Creset %C(green)(%cr)%Creset %s %C(blue)<%an>%Creset',
    '--follow',
    '--summary',
    commit_and_path[1],
    '--',
    commit_and_path[2]
  })
end

function buffer_commits()
  local comm_path = commit_and_path()
  local rel_path = require'fzf-lua'.path.relative(comm_path[2], vim.loop.cwd())
  local parsing_state = {filename = rel_path}
  vim.notify(vim.inspect(make_git_log_command(comm_path)))
  require'fzf-lua'.fzf_exec(make_git_log_command(comm_path), {
    fn_transform = function(line)
      if vim.startswith(line, ' rename') then
        -- Could be of form 'before.txt => after.txt' OR
        -- the terse 'somedir/{before.txt => after.txt}'
        local dir_or_full, remainder = string.match(line, "^ rename ([^{]+){?(.*) => ")
        remainder = remainder or ''
        parsing_state.filename = dir_or_full .. remainder
        return -- not an output line
      end
      if line == '' or vim.startswith(line, ' ') then
        -- discard other summary lines
        return
      end
      return parsing_state.filename .. ':' .. line
    end,
    fzf_opts = {
      ['--delimiter'] = '":| "',
    },
    preview = "git log --format=fuller -p --color --word-diff {2}~1..{2} -- {1}",
    actions={
      ['default'] = function(selected, opts)
        assert(#selected == 1)
        -- TODO(hoewelmk) also check for spaces (both renames and general handling)
        local file, commit = string.match(selected[1], "^([^:]*):(%x+) %(")
        local fugitive_path = vim.fn.FugitiveFind(commit .. ':' .. file)
        vim.cmd('edit ' .. fugitive_path)
      end
  }})
end

buffer_commits()

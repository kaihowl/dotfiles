# Profiling

Enable profiling by flipping the first line in the zshrc from "false"
to "true". This will for all new shells dump a start up profile to
~/tmp/startlog.<PID>.

You can use the following snippet to analyze the performance:

```zsh
function profile {
  local file
  file=$1

  paste \
    <(cut -d' ' -f1 $file | cat <(echo -n "\n") -) \
    <(cut -d' ' -f1-2 $file) \
  | awk '{ print $2-$1 " " $3 }' \
  | cut -d: -f1 \
  | awk '{map[$2] += 1} END {
      for (script in map) {
        if (map[script] > 100) {
          print script ": " map[script]
        }
      }
    }'
}
```

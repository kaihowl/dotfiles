# Implementation Plan: Flexible Date and Range Support for git-perf

## Overview

Extend `git-perf` to support more flexible commit range specifications, similar to `git log`. Currently, `git-perf audit` only supports `-n/--max-count` to limit the number of commits examined. This plan adds support for date-based filtering (`--since`, `--until`) and flexible range specifications.

## Current State

### Existing Implementation

- **Repository**: `kaihowl/git-perf` (Rust-based external tool)
- **Current flag**: `-n, --max-count <MAX_COUNT>` (default: 40)
- **Current behavior**: Examines the last N commits from HEAD using `--first-parent`
- **Git invocation**:
  ```bash
  git --no-pager log --no-color --ignore-missing -n <num_commits> \
    --first-parent --pretty=--,%H,%s,%an,%D%n%N --decorate=full \
    --notes=<temp_ref> <resolved_commit>
  ```

### Usage in dotfiles repository

- **Script**: `/root/repo/script/ci.sh:68`
  ```bash
  git perf audit -n 40 -m nvim -m zsh -m ci -m test -m nix-closure-size \
    -s "os=$os" --min-measurements 10
  ```

### Key Files (in git-perf repo)

- `git_perf/src/cli.rs` - Command-line argument parsing
- `git_perf/src/audit.rs` - Audit subcommand implementation
- `git_perf/src/measurement_retrieval.rs` - Commit walking wrapper
- `git_perf/src/git/git_interop.rs` - Git command invocation

## Proposed Changes

### 1. New Command-Line Options

Add the following options to `git perf audit` (and potentially other subcommands):

#### Date-Based Options

- `--since <date>` / `--after <date>`
  - Include commits more recent than specific date
  - Examples: `--since="2 weeks ago"`, `--since="2025-01-01"`, `--since="last monday"`
  - Accepts all formats that `git log --since` accepts

- `--until <date>` / `--before <date>`
  - Include commits older than specific date
  - Examples: `--until="yesterday"`, `--until="2025-12-31"`
  - Accepts all formats that `git log --until` accepts

#### Range Options

- `<revision-range>`
  - Support git revision range syntax as positional argument
  - Examples:
    - `main..feature` - commits in feature but not in main
    - `main...feature` - commits in either but not both (symmetric difference)
    - `HEAD~10..HEAD` - last 10 commits
    - `v1.0..v2.0` - commits between two tags

### 2. Implementation Strategy

#### Phase 1: Date-Based Filtering

1. **Update CLI argument parser** (`cli.rs`)
   - Add `--since` / `--after` options (type: `Option<String>`)
   - Add `--until` / `--before` options (type: `Option<String>`)
   - Make these options mutually compatible with `-n/--max-count`
   - Validation: Warn if both `-n` and date options are used (date options take precedence)

2. **Update git log invocation** (`git/git_interop.rs`)
   - Modify `walk_commits_from()` to accept date parameters
   - Build git log command dynamically:
     ```bash
     git --no-pager log --no-color --ignore-missing \
       [--since=<date>] [--until=<date>] [-n <num_commits>] \
       --first-parent --pretty=--,%H,%s,%an,%D%n%N --decorate=full \
       --notes=<temp_ref> <resolved_commit>
     ```
   - Ensure `--first-parent` is preserved for mainline tracking

3. **Update audit logic** (`audit.rs`)
   - Pass date parameters through the call chain
   - Update measurement retrieval to handle date-filtered commits
   - Ensure statistical analysis works with variable-length commit lists

4. **Add validation and warnings**
   - Warn if date range produces fewer commits than `--min-measurements`
   - Provide clear error messages for invalid date formats (let git handle validation)
   - Document that `--first-parent` is always used (important for PR-based workflows)

#### Phase 2: Revision Range Support

1. **Update CLI argument parser** (`cli.rs`)
   - Add optional positional argument for revision range
   - Type: `Option<String>`
   - Examples: `HEAD~10..HEAD`, `main..feature`, `v1.0..v2.0`

2. **Parse and validate revision ranges**
   - Use git to validate the range: `git rev-parse <range>`
   - Split ranges into start and end commits
   - Handle special cases:
     - `A..B` - commits reachable from B but not from A
     - `A...B` - symmetric difference (commits in either A or B but not both)
     - Single commit - just that commit and its ancestors (with `-n` or date limits)

3. **Update git log invocation**
   - Support passing ranges directly to `git log`:
     ```bash
     git --no-pager log --no-color --ignore-missing \
       [--since=<date>] [--until=<date>] [-n <num_commits>] \
       --first-parent --pretty=--,%H,%s,%an,%D%n%N --decorate=full \
       --notes=<temp_ref> <revision-range>
     ```
   - Note: When using ranges, `<resolved_commit>` is replaced with the range spec

4. **Handle range precedence**
   - Priority order: revision range > date filters > `-n` count
   - If revision range is specified:
     - Date filters can further restrict the range
     - `-n` limits the number of commits within the range
   - Clear documentation of how options interact

#### Phase 3: Enhanced Usability

1. **Add convenience options**
   - `--last-week` - Alias for `--since="1 week ago"`
   - `--last-month` - Alias for `--since="1 month ago"`
   - `--today` - Alias for `--since="midnight"`

2. **Improve output and diagnostics**
   - Display the actual date range being analyzed
   - Show total commits examined
   - Warn if insufficient historical data for statistical significance
   - Example output:
     ```
     Analyzing commits from 2025-12-01 to 2025-12-15
     Found 47 commits, 23 with measurements for 'nvim'
     ```

3. **Update documentation**
   - Add examples to README
   - Document interaction between options
   - Provide migration guide from `-n` to date-based filtering

### 3. Backward Compatibility

- **Preserve existing behavior**: `-n/--max-count` continues to work exactly as before
- **No breaking changes**: All existing scripts and CI configurations remain functional
- **Additive changes only**: New options are optional and don't affect existing usage
- **Default behavior unchanged**: Without new options, git-perf behaves identically

### 4. Testing Strategy

1. **Unit tests**
   - CLI argument parsing with various date formats
   - Validation of mutually exclusive options
   - Date format edge cases (relative dates, ISO 8601, etc.)

2. **Integration tests**
   - Test with real git repositories
   - Verify `--since` correctly filters commits
   - Verify `--until` correctly filters commits
   - Test range specifications (`A..B`, `A...B`)
   - Ensure `--first-parent` is always applied

3. **Edge cases**
   - Empty date ranges (no commits match)
   - Invalid date formats
   - Ranges with no measurements
   - Combining `-n`, `--since`, and `--until`
   - Very large date ranges (performance testing)

4. **Regression tests**
   - Ensure existing `-n` behavior is unchanged
   - Verify all existing CI scripts still work
   - Test with current dotfiles CI configuration

## Implementation Checklist

### Phase 1: Date-Based Filtering
- [ ] Add `--since`/`--after` CLI options in `cli.rs`
- [ ] Add `--until`/`--before` CLI options in `cli.rs`
- [ ] Update `walk_commits_from()` signature to accept date parameters
- [ ] Modify git log invocation to include date filters
- [ ] Update `audit.rs` to pass date parameters through call chain
- [ ] Add validation for date options
- [ ] Add warning when date range produces insufficient measurements
- [ ] Write unit tests for CLI parsing
- [ ] Write integration tests for date filtering
- [ ] Update README with date filter examples

### Phase 2: Revision Range Support
- [ ] Add revision range as optional positional argument in `cli.rs`
- [ ] Implement revision range validation using `git rev-parse`
- [ ] Handle `..` (range) syntax
- [ ] Handle `...` (symmetric difference) syntax
- [ ] Update git log invocation to accept ranges
- [ ] Define and document option precedence rules
- [ ] Write unit tests for range parsing
- [ ] Write integration tests for various range formats
- [ ] Update README with range examples

### Phase 3: Enhancements
- [ ] Add convenience date aliases (`--last-week`, `--last-month`, etc.)
- [ ] Enhance output to show analyzed date range
- [ ] Display commit count and measurement statistics
- [ ] Add detailed diagnostic warnings
- [ ] Create comprehensive documentation
- [ ] Write migration guide
- [ ] Add examples for common use cases

### Testing & Quality
- [ ] All unit tests passing
- [ ] All integration tests passing
- [ ] Edge case testing complete
- [ ] Regression testing with dotfiles CI
- [ ] Performance testing with large repositories
- [ ] Documentation review
- [ ] Code review

## Examples of New Usage

### Date-Based Filtering

```bash
# Analyze commits from the last 2 weeks
git perf audit --since="2 weeks ago" -m nvim -m zsh

# Analyze commits in December 2025
git perf audit --since="2025-12-01" --until="2025-12-31" -m ci

# Analyze today's commits
git perf audit --since="midnight" -m test

# Combine with count limit (analyze last 20 commits from past month)
git perf audit --since="1 month ago" -n 20 -m nvim
```

### Range-Based Filtering

```bash
# Analyze commits between two tags
git perf audit v1.0..v2.0 -m nvim -m zsh

# Analyze last 10 commits
git perf audit HEAD~10..HEAD -m ci

# Analyze commits in feature branch not in main
git perf audit main..feature -m test

# Analyze symmetric difference between branches
git perf audit main...feature -m nvim
```

### Combined Usage

```bash
# Analyze commits in a range, but only from last week
git perf audit --since="1 week ago" main..feature -m nvim

# Analyze last 10 commits from past month
git perf audit --since="1 month ago" -n 10 -m zsh
```

## Migration Impact

### dotfiles Repository

The current usage in `/root/repo/script/ci.sh:68` will continue to work without changes:

```bash
# Existing (no changes required)
git perf audit -n 40 -m nvim -m zsh -m ci -m test -m nix-closure-size \
  -s "os=$os" --min-measurements 10

# Could optionally be updated to use date-based filtering
git perf audit --since="6 months ago" -m nvim -m zsh -m ci -m test \
  -m nix-closure-size -s "os=$os" --min-measurements 10
```

### Benefits for dotfiles

1. **Historical analysis**: Easily analyze performance trends over specific time periods
2. **Release auditing**: Compare performance between tagged releases
3. **Flexible CI**: Adjust audit scope based on time since last run
4. **Better debugging**: Narrow down when performance regressions were introduced

## Dependencies

- **git-perf repository**: `kaihowl/git-perf`
- **Git version**: Requires git 1.7.0+ (for `--since`/`--until` support)
- **No new external dependencies**: Uses existing git functionality

## Timeline Considerations

This is a feature enhancement to an external tool (`git-perf`), not this repository. Implementation steps:

1. Fork or contribute to `kaihowl/git-perf`
2. Implement changes following the phases above
3. Submit pull request to upstream repository
4. Update dotfiles to use new version once merged
5. Optionally update CI scripts to leverage new features

## Open Questions

1. Should we maintain strict backward compatibility, or is this a good opportunity for a major version bump?
2. Should date filtering work with other subcommands (`add`, `measure`, `push`), or just `audit`?
3. How should we handle ambiguous date formats (let git handle it vs. explicit validation)?
4. Should we add a `--dry-run` flag to show which commits would be analyzed?
5. What's the best way to communicate when date filters produce insufficient data for statistical analysis?

## References

- git-perf repository: `kaihowl/git-perf`
- git log documentation: https://git-scm.com/docs/git-log
- git revision range syntax: https://git-scm.com/docs/gitrevisions
- Current usage in dotfiles: `/root/repo/script/ci.sh:68`, `/root/repo/common/perf.sh`

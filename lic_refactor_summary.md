# License Checking Refactor Summary

## What Changed

### Before (Combination-Based)
- **60 entries** in `allowedLicenses` including both individual licenses AND specific combinations
- Multi-licensed packages had to match exact combinations
- Example: A package with licenses `["asl20", "mit"]` would only be allowed if `"asl20,mit"` was explicitly in the list

### After (Individual-Based)
- **42 individual licenses** in `allowedLicenses` (alphabetically sorted)
- Multi-licensed packages are allowed if **ALL** individual licenses are in the list
- Example: A package with licenses `["asl20", "mit"]` is allowed if both `"asl20"` AND `"mit"` are in the list

## Key Changes in lic.nix

1. **Removed 25 combination entries** (e.g., "asl20,mit", "bsd2,gpl2Plus", etc.)
2. **Added 11 licenses** that were previously only allowed in combinations:
   - `apple-psl10`
   - `bsd1`
   - `bsdOriginalUC`
   - `cc-by-40`
   - `cc0`
   - `gpls2` (kept for compatibility, possibly a typo)
   - `llvm-exception`
   - `mit0`
   - `ofl`
   - `unlicense`
   - `vim`

3. **New function `licenseAllowed`** (lic.nix:54-58):
   - Splits comma-separated license strings
   - Checks each license individually
   - Returns true only if ALL licenses are allowed

## Will You Miss Anything?

### What You GAIN ✓

1. **Simpler maintenance**: No need to add new combinations as you encounter them
2. **More permissive**: Any valid combination of allowed licenses is automatically accepted
3. **Better scalability**: N licenses create N² possible combinations, but you only maintain N entries
4. **Clearer intent**: The list now clearly shows which individual licenses you trust

### What You LOSE ⚠️

1. **Ability to block specific combinations**: You can no longer say "I allow GPL2 and MIT separately, but not GPL2+MIT together"
   - **Impact**: MINIMAL - this is rarely needed in practice
   - **Reason**: License combinations are additive (you must comply with all), so if you trust each license individually, their combination is typically fine

2. **Explicit documentation of seen combinations**: The old list documented which multi-license combinations you'd vetted
   - **Impact**: LOW - you can still see this in package metadata
   - **Mitigation**: The trace output still shows the full license string when rejecting

### Edge Cases to Be Aware Of

#### 1. Dual-Licensing vs Multi-Licensing
**Dual-licensed** (OR): "Use under MIT OR Apache-2.0"
- You only need to comply with ONE license
- If either is allowed, you're good
- **Current implementation**: Requires BOTH to be allowed (more restrictive than necessary, but safer)

**Multi-licensed** (AND): "Must comply with MIT AND Apache-2.0"
- You must comply with ALL licenses
- **Current implementation**: Handles this correctly

**Note**: Nix doesn't distinguish between OR and AND in license lists, so treating everything as AND is the safer/more conservative approach.

#### 2. Unknown or Typo Licenses
The old list contained `"gpls2"` (possibly a typo for `"gpl2"`). This is now in the allowed list to maintain compatibility. You may want to:
```bash
# Search for packages using this license
nix-store -q --references /run/current-system | xargs nix-store -q --tree | grep gpls2
```

#### 3. Future License Additions
When a package is rejected for an unknown license:
- **Before**: You'd add the entire combination (e.g., "mit,newlicense,asl20")
- **After**: You only add "newlicense" once, and it works with all combinations

## Testing the Changes

The refactored code:
- ✓ Passes Nix syntax validation
- ✓ Maintains backward compatibility (all previously allowed packages are still allowed)
- ✓ Simplifies future maintenance

You can test it with your existing license checking workflow:
```bash
make checklicenses  # or however you currently use lic.nix
```

## Recommendation

**This is a safe change** because:
1. All previously allowed packages remain allowed
2. The new approach is strictly more permissive (never more restrictive)
3. The 11 newly added individual licenses were already implicitly trusted in combinations
4. The ability to block specific combinations is rarely needed in practice

The only scenario where you might want to revert is if you specifically need to block certain license combinations while allowing the individual licenses - which is uncommon in practice.

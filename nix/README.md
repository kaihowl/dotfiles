# Maintenance operations

## Determine if GC ROOT pinning works

Inputs of nix are not directly referenced by any symlink and are therefore
subject to garbage collection. To prevent garbage collection, we introduced an
explicit GC ROOT. Use the makefile's full target to run with sufficient logging
to output the source used for the inputs. Then make sure that the used input's
store paths are held (indirectly) by a live GC root.

```
nix-store --query --roots /nix/store/26h92s5nj1h7ky9bk6yf71am5zc121j8-source
```

This would for example determine if the object is still alive by returning at
least one live GC root referencing it.

There is also a test that tries to rerun the install after the GC was invoked:
If there is any download/copying from a remote mentioned in the logs, the test
will fail.


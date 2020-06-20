# Why cannot we design a script could be both source and executed at the same time

To support "eval" way to import script
And in bash 3 in macos, '. <(curl xxx)' is not supported.

```bash
if [ "$0" = "${BASH_SOURCE[0]}" ]; then
    # run the code
fi
```

```
@src std/str.join "a" 1 2 3

@src std/doctest
doctest.run file file2 file3

@src.main std/doctest file file2 file3
( @src std/doctest; doctest.run file file2 file3 )

@src.bash setup/docker
```

```
curl https://setup.x-bash.com/docker | bash
@src.run setup/docker

# We should use x instead of bash. If we just need to run, instead of upload. This is OK.
@src.bash https://edwinjhlee.github.io/work/a.sh

# download x, then run
@src.x https://edwinjhlee.github.io/work/a.sh

@src.x bash https://edwinjhlee.github.io/work/a.sh
```



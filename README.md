# repeat

string repetition tool for Batch Script.

# Syntax
```bat
repeat [options] string * count
```

# Options
- `-h`|`--help` - writes help and exits
- `-v`|`--version` - writes version and exits
- `-i`|`--interactive` - fall in interactive mode
- `--` - ends option list

If string is specified before some option then it is ignored.

Interactive mode commands:
- `q`|`quit` - exits
- `c`|`clear` - clears screen
- `h`|`help` - writes help
- `--` - makes possible to use interactive mode commands as strings to repeat

# Error codes
- `0` - Success
- `10` - Other options or string repetitions are not allowed after first string repetition construction.
- `20` - Asterisk delimiter is not specified after string to repeat.
- `21` - Repetition count is not specified after asterisk delimiter.

# Examples
```bat
repeat --help
```
```bat
repeat abc * 10
```
```bat
repeat abc * 10 --help
```

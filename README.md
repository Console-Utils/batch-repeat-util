# String repeater

## Description

> ⚠️ This project is no longer maintained.

Tool to duplicate passed string as much as required.

## Syntax

```bat
repeat [options] string * count
```

## Options

- `-h`|`--help` - writes help and exits
- `-v`|`--version` - writes version and exits
- `-i`|`--interactive` - fall in interactive mode
- `--` - ends option list

### Interactive

Interactive mode commands:
- `q`|`quit` - exits
- `c`|`clear` - clears screen
- `h`|`help` - writes help
- `--` - makes possible to use interactive mode commands as strings to repeat

## Return codes
- `0` - Success
- `10` - Other options or string repetitions are not allowed after first string repetition construction.
- `20` - Asterisk delimiter is not specified after string to repeat.
- `21` - Repetition count is not specified after asterisk delimiter.

## Notes

If string is specified before some option then it is ignored.

## Examples
```bat
repeat --help
```
```bat
repeat abc * 10
```
```bat
repeat abc * 10 --help
```


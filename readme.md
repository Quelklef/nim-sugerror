# sugerror

Templates for terse and composable error handling in Nim.

# Installation

Sugerror is on nimble. Run:

```bash
nimble update
nimble install sugerror
```

then just

```nim
import sugerror
```

in your Nim code.

# Explanatory examples

## Exceptions to Default Values

Suppose you have some string `input` that you get from the user. You want to parse it into an integer,
with a default value `0`. With sugerror, this can be done in any of the following manners:

```nim
var x: int
try:
  x = parseInt(input)
except ValueError:
  x = 0
```

`sugerror.catch` returns a given default value if the given exception is raised.

```nim
let x = parseInt(input).catch(ValueError, 0)
```

If `catch` is not given an exception, it catches all catchable exceptions.

```nim
let x = parseInt(input).catch(0)
```

## Exceptions to Options

Suppose you don't want to have a default value `0` but instead would like to make `x` be an `Option[int]`
depending on whether `input` is a valid integer or not.

```nim
var x: Option[int]
try:
  x = some(parseInt(input))
except ValueError:
  x = none(int)
```

`sugerror.toOption` boxes the expression in an `Option` based on whether or not the given exception was raised.

```nim
let x = parseInt(input).toOption(ValueError)
```

If `toOption` is not given an exception, it catches all catchable exceptions.

```nim
let x = parseInt(input).toOption
```

## Exceptions to Exceptions

Sometimes you want to let an exception propogate, but change what the exception is. For instance, say
you want to catch a `KeyError` and raise a custom `TableError`. The following examples use
`TableError: ref Exception`, `table: Table[string, int]`, and `key: string`:

```nim
var val: int
try:
  val = table[key]
except KeyError:
  raise TableError.newException("Hey, buddy, that key doesn't exist!")
```

This can also be done with `sugerror.reraise`:

```nim
let val = table[key].reraise(KeyError, TableError.newException("Hey, buddy, that key doesn't exist!"))
```

If `reraise` is supplied a type instead of an error, the error type will be instantiated with the current
exception msg.

```nim
let val = table[key].reraise(KeyError, TableError)
# is equivalent to
let val = table[key].reriase(KeyError, TableError.newException(getCurrentExceptionMsg()))
```

`reraise` can also be used with statements instead of expressions:

```nim
var val: int
reraise(KeyError, ValueError):
  val = table[key]
```

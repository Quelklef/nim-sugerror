# sugerror

Templates for terse and composable error handling in Nim.

# Explanatory examples

## Exceptions to Default Values

Suppose you have some string `input` that you get from the user. You want to parse it into an integer,
with a default value `0`. With sugerror, this can be done in any of the following manners:

#### The vanilla way:

```nim
var x: int
try:
  x = parseInt(input)
except ValueError:
  x = 0
```

#### `sugerror.catch`:

`catch` returns a given default value if the given exception is raised.

```nim
let x = parseInt(input).catch(ValueError, 0)
```

#### `sugerror.catch` (2):

If `catch` is not given an exception, it catches all catchable exceptions.

```nim
let x = parseInt(input).catch(0)
```

## Exceptions to Options

Suppose you don't want to have a default value `0` but instead would like to make `x` be an `Option[int]`
depending on whether `input` is a valid integer or not.

#### The vanilla way:

```nim
var x: Option[int]
try:
  x = some(parseInt(input))
except ValueError:
  x = none(int)
```

#### `sugerror.toOption`

`toOption` boxes the expression in an `Option` based on whether or not the given exception was raised.

```nim
let x = parseInt(input).toOption(ValueError)
```

#### `sugerror.toOption` (2):

If `toOption` is not given an exception, it catches all catchable exceptions.

```nim
let x = parseInt(input).toOption
```

## Exceptions to Exceptions

Sometimes you want to let an exception propogate, but change what the exception is. For instance, say
you want to catch a `KeyError` and reraise a `ValueError` with some custom text. The following
examples use `table: Table[string, int]` and `key: string`

#### The vanilla way:

```nim
var val: int
try:
  val = table[key]
except KeyError:
  raise ValueError.newException("Hey, buddy, that key doesn't exist!")
```

#### `sugerror.reraise`:

```nim
let val = table[key].reraise(KeyError, ValueError.newException("Key, buddy, that key doesn't exist!"))
```

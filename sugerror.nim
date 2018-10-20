import options

template toOption*[T, X](expr: T; ex: typedesc[X]): Option[T] =
  ## Maps an exception to an Option.
  ## If the expression raises the given exception, returns ``none(T)``.
  ## Else, returns ``some(expr)``.
  ##
  ## For example:
  ##
  ## ..code-block:: nim
  ##   "3".parseInt.toOption(ValueError) == some(3)
  ##   "three".parseInt.toOption(ValueError) == none(int)
  block:
    var res: Option[T]
    try:
      res = some(expr)
    except ex:
      res = none(T)
    res

template toOption*[T](expr: T): Option[T] =
  ## Maps an exception to an Option.
  ## If the expression raises a catchable exception, returns ``none(T)``.
  ## Else, returns ``some(expr)``.
  ##
  ## For example:
  ##
  ## ..code-block:: nim
  ##   "3".parseInt.toOpion == some(3)
  ##   "three".parseInt.toOption == none(int)
  block:
    var res: Option[T]
    try:
      res = some(expr)
    except:
      res = none(T)
    res

template catch*[T, X](expr: T; ex: typedesc[X]; default: T): T =
  ## Maps an exception to a value.
  ## If the expression raises the given exception, returns ``default``.
  ## Else, returns ``expr``.
  ##
  ## For example:
  ##
  ## ..code-block:: nim
  ##   "3".parseInt.catch(ValueError, -1) == 3
  ##   "three".parseInt.catch(ValueError, -1) == -1
  block:
    var res: T
    try:
      res = expr
    except ex:
      res = default
    res

template catch*[T](expr: T; default: T): T =
  ## Maps an exception to a value.
  ## If the expression raises a catchable exception, returns ``default``.
  ## Else, returns ``some(expr)``.
  ##
  ## For example:
  ##
  ## ..code-block:: nim
  ##   "3".parseInt.catch(-1) == 3
  ##   "three".parseInt.catch(-1) == -1
  block:
    var res: T
    try:
      res = expr
    except:
      res = default
    res

template reraise*[T, XF, XT: Exception](expr: T; exFrom: typedesc[XF]; exTo: XT): T =
  ## Maps an exception to an exception.
  ## If the expression raises an exception of the type ``exFrom``, raises ``exTo``.
  ## Else, returns ``expr``.
  ##
  ## For example:
  ##
  ## ..code-block:: nim
  ##   let x = some(1)
  ##   echo(x.get.reraise(UnpackError, ValueError.newException("Need an int!"))  # fine
  ##   let y = none(int)
  ##   echo(x.get.reraise(UnpackError, ValueError.newException("Need an int!"))  # raises ValueError
  block:
    var res: T
    try:
      res = expr
    except exFrom:
      raise exTo

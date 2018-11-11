import options

when isMainModule:
  import strutils

template toOption*[T; X](expr: T; ex: typedesc[X]): Option[T] =
  ## Maps an exception to an Option.
  ## If the expression raises the given exception, returns ``none(T)``.
  ## Else, returns ``some(expr)``.
  ##
  ## For example:
  ##
  ## ..code-block:: nim
  ##   "3".parseInt.toOption(ValueError) == some(3)
  ##   "three".parseInt.toOption(ValueError) == none(int)

  # I would much prefer the following be
  # var res: Option[T]
  # try: res = some(expr)
  # except ex: res = none(T)
  # But that doesn't work for some reason
  block:
    var res = none[T]()
    try:
      res = some(expr)
    except ex:
      discard
    res

when isMainModule:
  assert("3".parseInt.toOption(ValueError) == some(3))
  assert("t".parseInt.toOption(ValueError) == none(int))

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
    var res = none[T]()
    try:
      res = some(expr)
    except:
      discard
    res

when isMainModule:
  assert("3".parseInt.toOption == some(3))
  assert("t".parseInt.toOption == none(int))

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

when isMainModule:
  assert("3".parseInt.catch(ValueError, 0) == 3)
  assert("t".parseInt.catch(ValueError, 0) == 0)

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

when isMainModule:
  assert("3".parseInt.catch(0) == 3)
  assert("t".parseInt.catch(0) == 0)

template reraise*[T; XF, XT](expr: T; exFrom: typedesc[XF]; exTo: XT): T =
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
    res

template reraise*[T; XF, XT](expr: T; exFrom: typedesc[XF]; exTo: typedesc[XT]): T =
  ## Equivalent to ``expr.reraise(exFrom, exTo.newException(getCurrentExceptionMsg()))``
  expr.reraise(exFrom, exTo.newException(getCurrentExceptionMsg()))

template reraise*[XF, XT](exFrom: typedesc[XF]; exTo: XT, blc: untyped) =
  ## Maps an exception to an exception.
  ## Works on statement blocks rather than expressions.
  ## If the block raises an exception of the type ``exFrom``, raises ``exTo``.
  ##
  ## For example:
  ##
  ## ..code-block:: nim
  ##   reraise(UnpackError, ValueError.newException("Need an int!")):
  ##      some(108).get()  # fine
  ##      none(int).get()  # raises ValueError
  try:
    blc
  except exFrom:
    raise exTo

template reraise*[XF, XT](exFrom: typedesc[XF]; exTo: typedesc[XT]; blc: untyped) =
  ## Equivalent to ``reraise(exFrom, exTo.newException(getCurrentExceptionMsg())): blc``
  try:
    blc
  except exFrom:
    raise exTo.newException(getCurrentExceptionMsg())

when isMainModule:
  try:
    let x = "t".parseInt.reraise(ValueError, OSError.newException(""))
    assert(false)
  except OSError:
    assert(getCurrentExceptionMsg() == "")

  try:
    let x = "t".parseInt.reraise(ValueError, OSError)
    assert(false)
  except OSError:
    assert(getCurrentExceptionMsg() == "invalid integer: t")

  try:
    reraise(ValueError, OSError.newException("")):
      let x = "t".parseInt
    assert(false)
  except OSError:
    assert(getCurrentExceptionMsg() == "")

  try:
    reraise(ValueError, OSError):
      let x = "t".parseInt
    assert(false)
  except OSError:
    assert(getCurrentExceptionMsg() == "invalid integer: t")

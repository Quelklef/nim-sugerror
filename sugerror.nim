import options

template toOption*[T, X](expr: T; ex: typedesc[X]): Option[T] =
  ## Maps an exception to an Option
  ## If the expression raises the given exception, returns ``none(T)``
  ## else, returns ``some(expr)``
  block:
    var res: Option[T]
    try:
      res = some(expr)
    except ex:
      res = none(T)
    res

template catch*[T, X](expr: T; ex: typedesc[X]; default: T): T =
  ## Maps an exception to a value
  ## If the expression raises the given exception, returns ``default``
  ## else, returns ``expr``
  block:
    var res: T
    try:
      res = expr
    except ex:
      res = default
    res

template reraise*[T, XF, XT: Exception](expr: T; exFrom: typedesc[XF]; exTo: XT): T =
  ## Returns ``expr`` unless an exception is raised; if
  ## the exception is of the type ``XF``, instead raises the given exception
  block:
    var res: T
    try:
      res = expr
    except exFrom:
      raise exTo

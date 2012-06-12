root = @
Linc = exports? and @ or @Linc = {}
Linc._functions = {}
Linc._defaults = {
  namespace : ''
  context   : root
}

Linc.add = ->
  name      = arguments[0]
  initFn    = arguments[ arguments.length - 1 ]
  nsNames   = []

  widget = {
    options : if isObject( arguments[1] ) then arguments[1] else {}
    init: initFn
  }

  if ~name.indexOf '.'
    nsNames = name.split '.'
    name    = nsNames.shift()
  else if @_defaults.namespace
    nsNames = @_defaults.namespace.split '.'

  if nsNames.length
    for ns in nsNames
      @_functions[ ns ] ?= {}
      @_functions[ ns ][ name ] = widget
  else
    @_functions[ name ] = widget

Linc.run = ( o ) ->
  o ?= {}
  context   = o.context   ? @_defaults.context
  namespace = o.namespace ? @_defaults.namespace
  all       = o.all

  if all
    namespace = for own name, namespace of @_functions when not isFunction namespace.init
      name
  else
    namespace = if isArray namespace then namespace else [ namespace ]

  # Adds unscoped widgets
  namespace.push null

  for ns in namespace
    funcs = @_functions[ ns ] ? @_functions
    for own name, widget of funcs when isFunction( widget.init )
      unless widget.options.once and widget.called
        widget.init.call( context )
        widget.called = true

Linc.setDefaults = ( o ) ->
  for own option, value of o
    @_defaults[ option ] = value
  @_defaults

# Helpers
isArray = Array.isArray ? ( o ) -> Object::toString.call( o ) is '[object Array]'
isFunction = ( o ) -> Object::toString.call( o ) is '[object Function]'
isObject = ( o ) -> o is Object o

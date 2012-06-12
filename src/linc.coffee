Linc = exports? and @ or @Linc = {}

Linc._functions = {}

Linc.add = ->
  name      = arguments[0]
  options   = {}
  initFn    = arguments[ arguments.length - 1 ]
  functions = @_functions

  if isObject arguments[1]
    options = arguments[1]

  register = ( ns ) ->
    funcs = if ns then functions[ ns ] ?= {} else functions
    funcs[ name ] = {
      options : options
      init : initFn
    }

  if ~name.indexOf '.'
    nsNames = name.split('.')
    name    = nsNames.shift()
    register ns for ns in nsNames
  else
    register()

Linc.run = ( o ) ->
  o ?= {}
  scope = o.scope ? document
  ns    = o.namespace ? []
  all   = o.all

  if all
    ns = for own key of @_functions when isObject key
      key
  else
    ns = if isArray ns then ns else [ ns ]

  runFuncs namespaces for namespaces in ns
  runFuncs()

  runFuncs = ( namespace ) ->
    funcs = @_functions[ namespace ] ? @_functions
    for own name, widget of funcs
      unless widget.options.once and widget.called
        widget.init.call( scope )
        widget.called = true

# Helpers
isArray = Array.isArray ? ( o ) -> Object::toString.call( o ) is '[object Array]'
isFunction = ( o ) -> Object::toString.call( o ) is '[object Function]'
isObject = ( o ) -> o is Object o

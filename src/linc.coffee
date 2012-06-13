root = @
Linc = exports? and @ or @Linc = {}
Linc._functions = {}
Linc._defaults = {
  namespace : []
  context   : root
}

Linc.add = ->
  nameObj = parseNames arguments[0]
  initFn  = arguments[ arguments.length - 1 ]
  name    = nameObj.name
  nSpace  = nameObj.namespaces

  return null unless name

  module =
    options : if isObject( arguments[1] ) then arguments[1] else {}
    init    : initFn

  if nSpace and nSpace.length
    for ns in nSpace
      @_functions[ ns ] ?= {}
      @_functions[ ns ][ name ] = module
  else
    @_functions[ name ] = module
  module

Linc.get = ( name ) ->
  nameObj = parseNames name
  name    = nameObj.name
  ns      = nameObj.namespaces.shift()
  module  = if ns then @_functions[ ns ][ name ] else @_functions[ name ]

Linc.run = () ->
  args    = arguments
  nameObj = if args.length and not isObject( args[0] ) then parseNames( args[0] ) else {}

  name   = nameObj.name
  nSpace = nameObj.namespaces ? @_defaults.namespace.slice 0

  o       = if isObject( args[ args.length - 1 ] ) then args[ args.length - 1 ] else {}
  context = o.context ? @_defaults.context
  all     = o.all
  data    = o.data ? []
  namespaceOnly = o.namespaceOnly

  if all
    nSpace = for own key, ns of @_functions when not isFunction ns.init
      key

  nSpace.push null unless namespaceOnly

  if name
    @get( args[0] ).init.call( context, data )
  else
    for ns in nSpace
      funcs = @_functions[ ns ] ? @_functions
      for own name, module of funcs when isFunction( module.init )
        unless module.options.once and module.called
          module.init.call( context, data )
          module.called = true
  Linc

Linc.setDefaults = ( o ) ->
  for own option, value of o
    if option is 'namespace'
      @_defaults[ option ] = if isArray( value ) then value else []
      @_defaults[ option ].push value if not @_defaults[ option ].length and value
    else
      @_defaults[ option ] = value
  @_defaults

# Helpers
parseNames = ( s ) ->
  split = s.match /^([^\.]*)?(?:\.(.+))?$/
  returnObj =
    name       : split[1]
    namespaces : split[2]?.split('.') ? Linc._defaults.namespace.slice 0

isArray = Array.isArray ? ( o ) -> Object::toString.call( o ) is '[object Array]'
isFunction = ( o ) -> Object::toString.call( o ) is '[object Function]'
isObject = ( o ) -> o is Object( o ) and not isFunction o

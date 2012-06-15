###
linc
js execution controller
@weblinc, @jsantell (c) 2012
###

# Bindings and Initialization

root = @
Linc = exports? and @ or @Linc = {}
Linc._functions = {}
Linc._defaults = {
  namespace : []
  context   : root
}

# Linc Methods

Linc.add = ->
  nMap = @_parseNames arguments[0]
  options = @_makeOptions arguments[1]
  initFn  = arguments[ arguments.length - 1 ]

  return null unless nMap.name

  module =
    options : options
    init    : initFn
    called  : 0

  if nMap.namespaces.length
    for ns in nMap.namespaces
      ( @_functions[ ns ] ?= {} )[ nMap.name ] = module
  else
    @_functions[ nMap.name ] = module
  module

Linc.get = ( name ) ->
  nMap = @_parseNames name
  ( @_functions[ nMap.namespaces.shift() ] ? @_functions )[ nMap.name ]

Linc.run = () ->
  args    = arguments
  nMap    = @_parseNames arguments[0]
  o       = @_makeOptions arguments[ arguments.length - 1 ]
  context = o.context ? @_defaults.context
  all     = o.all
  data    = o.data
  nsOnly  = o.namespaceOnly

  if all
    for own key, ns of @_functions
      unless isFunction ns.init
        ( nMap.namespaces ?= [] ).push key

  ( nMap.namespaces ?= [] ).push null unless nsOnly
  if nMap.name
    @_call @get( args[0] ), context, data
  else
    for ns in nMap.namespaces
      for own name, module of ( @_functions[ ns ] ? @_functions )
        @_call module, context, data
  @

Linc.setDefaults = ( o ) ->
  for own option, value of o
    if option is 'namespace'
      @_defaults[ option ] = if isArray( value ) then value else [ value ]
    else
      @_defaults[ option ] = value
  @_defaults

# Linc Utilites

Linc._call = ( module, context, data ) ->
  if isFunction( module.init )
    unless module.options.once and module.called
      module.init.call( context, data )
      module.called++;

Linc._parseNames = ( s ) ->
  s = '' if not s or isObject( s )
  split = s.match /^([^\.]*)?(?:\.(.+))?$/
  returnObj =
    name       : split[1]
    namespaces : split[2]?.split('.') ? @_defaults.namespace.slice 0

Linc._makeOptions = ( o ) ->
  if isObject( o ) then o else {}

# Type Checking Utilities

isArray = Array.isArray ? ( o ) ->
  Object::toString.call( o ) is '[object Array]'

isFunction = ( o ) ->
  Object::toString.call( o ) is '[object Function]'

isObject = ( o ) ->
  o is Object( o ) and not isFunction o

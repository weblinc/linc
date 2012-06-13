Linc = require('../src/linc')
root = if module? then Linc else @
context = null
bCalls = 0
a_fn = jasmine.createSpy()
b_fn = () -> bCalls++
x_fn = jasmine.createSpy()
y_fn = jasmine.createSpy()
z_fn = () ->
  context = @

b_namespace = { namespace: Math.random() }

describe 'add', ->
  describe 'unnamespaced widgets', ->
    wA = Linc.add 'widgetA', a_fn
    wB = Linc.add 'widgetB', { once : true }, b_fn

    it 'should add widget to root of fn store', ->
      expect( Linc._functions.widgetA ).toBeTruthy()
      expect( Linc._functions.widgetB ).toBeTruthy()
    it 'should add widget with correct options and initFn', ->
      expect( Linc._functions.widgetA.init ).toBe a_fn
      expect( Linc._functions.widgetB.init ).toBe b_fn
      expect( Linc._functions.widgetA.options.once ).toBeFalsy()
      expect( Linc._functions.widgetB.options.once ).toBeTruthy()
    it 'should return the module when adding', ->
      wA.testVal = 'death metal'
      wB.testVal = 'rocks'
      expect( Linc._functions.widgetA.init ).toBe a_fn
      expect( Linc._functions.widgetB.init ).toBe b_fn
      expect( Linc._functions.widgetA.testVal ).toEqual wA.testVal
      expect( Linc._functions.widgetB.testVal ).toEqual wB.testVal

  describe 'widgets with single namespace', ->
    Linc.add 'widgetX.namespaceA', x_fn
    Linc.add 'widgetY.namespaceB', y_fn
    Linc.add 'widgetZ.namespaceA', z_fn

    it 'should not add widget to root namespace in fn store', ->
      expect( Linc._functions.widgetX ).toBeFalsy()
      expect( Linc._functions.widgetY ).toBeFalsy()
      expect( Linc._functions.widgetZ ).toBeFalsy()
    it 'should add widget to namespace in fn store', ->
      expect( Linc._functions.namespaceA.widgetX.init ).toBe x_fn
      expect( Linc._functions.namespaceB.widgetY.init ).toBe y_fn
      expect( Linc._functions.namespaceA.widgetZ.init ).toBeTruthy()

describe 'run', ->

  describe 'running unnamespaced widgets', ->
    it 'should call all unnamespaced widgets, no namespaced widgets', ->
      Linc.run()
      expect( a_fn ).toHaveBeenCalled()
      expect( bCalls ).toBe( 1 )
      expect( x_fn ).not.toHaveBeenCalled()
      expect( y_fn ).not.toHaveBeenCalled()
    it 'should only call widgets with "once" once', ->
      Linc.run()
      Linc.run()
      expect( bCalls ).toBe( 1 )

  describe 'running with namespaces', ->
    w_fn = null
    beforeEach ->
      a_fn = jasmine.createSpy()
      w_fn = jasmine.createSpy()
      x_fn = jasmine.createSpy()
      y_fn = jasmine.createSpy()
      Linc.add 'widgetA', a_fn
      Linc.add 'widgetW.namespaceW', w_fn
      Linc.add 'widgetX.namespaceA', x_fn
      Linc.add 'widgetY.namespaceB', y_fn

    it 'should call specified namespace and unscoped', ->
      Linc.run('.namespaceA')
      expect( a_fn ).toHaveBeenCalled()
      expect( w_fn ).not.toHaveBeenCalled()
      expect( x_fn ).toHaveBeenCalled()
      expect( y_fn ).not.toHaveBeenCalled()

    it 'should call specified namespaces in array and unscoped', ->
      Linc.run('.namespaceA.namespaceB')
      expect( a_fn ).toHaveBeenCalled()
      expect( x_fn ).toHaveBeenCalled()
      expect( y_fn ).toHaveBeenCalled()
      expect( w_fn ).not.toHaveBeenCalled()

    it 'should call all namespaces when "all" is set', ->
      Linc.run({ all: true })
      expect( a_fn ).toHaveBeenCalled()
      expect( x_fn ).toHaveBeenCalled()
      expect( y_fn ).toHaveBeenCalled()
      expect( w_fn ).toHaveBeenCalled()

    it 'should call only the namespace, not unscoped', ->
      Linc.run('.namespaceW', { namespaceOnly: true })
      expect( a_fn ).not.toHaveBeenCalled()
      expect( x_fn ).not.toHaveBeenCalled()
      expect( y_fn ).not.toHaveBeenCalled()
      expect( w_fn ).toHaveBeenCalled()

  describe 'running with contexts', ->
    it 'should use default context if non specified', ->
      Linc.run('.namespaceA')
      expect( context ).toBe( Linc._defaults.context )
    it 'should pass in the correct context', ->
      testContext = { test: 'context' }
      Linc.run('.namespaceA', { context: testContext })
      expect( context ).toBe( testContext )

describe 'setDefaults', ->

  it 'should have correct defaults', ->
    Linc.add('contextWidget', z_fn)
    Linc.run()
    # Checks default context
    expect( context ).toBe( root )
    # Checks default namespace
    expect( Linc._functions.contextWidget.init ).toBeTruthy()

  it 'should use set defaults for context', ->
    testContext = { test: 'context' }
    Linc.setDefaults { context: testContext }
    Linc.run()
    expect( context ).toBe( testContext )

  it 'should add and run default namespace', ->
    nsSpy = jasmine.createSpy()
    Linc.setDefaults { namespace: 'testNS' }
    Linc.add( 'megaman', nsSpy )
    Linc.run()
    expect( Linc._functions.testNS.megaman ).toBeTruthy()
    expect( nsSpy ).toHaveBeenCalled()

describe 'get', ->
  it 'should return the correct unscoped module', ->
    Linc.setDefaults { namespace: [] }
    wA = Linc.add 'testGetA', a_fn
    wB = Linc.add 'testGetB', b_fn
    expect( Linc.get( 'testGetA' )).toBe wA
    expect( Linc.get( 'testGetB' )).toBe wB
    expect( Linc.get( 'testGetA' ).init).toBe a_fn
    expect( Linc.get( 'testGetB' ).init).toBe b_fn
  
  it 'should return the correct scoped module', ->
    wC = Linc.add 'testGetC.scope', ( c_fn = jasmine.createSpy() )
    wD = Linc.add 'testGetD.scope', ( d_fn = jasmine.createSpy() )
    expect( Linc.get( 'testGetC.scope' )).toBe wC
    expect( Linc.get( 'testGetD.scope' )).toBe wD
    expect( Linc.get( 'testGetC.scope' ).init).toBe c_fn
    expect( Linc.get( 'testGetD.scope' ).init).toBe d_fn


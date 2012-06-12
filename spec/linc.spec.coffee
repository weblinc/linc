Linc = require('../src/linc')

a_fn = jasmine.createSpy()
b_fn = jasmine.createSpy()

b_scope = { scope: Math.random() }

describe 'add', ->
  describe 'unscoped widgets', ->
    Linc.add 'widgetA', a_fn
    Linc.add 'widgetB', { once : true }, b_fn

    it 'should add widget to root of fn store', ->
      expect( Linc._functions.widgetA ).toBeTruthy()
      expect( Linc._functions.widgetB ).toBeTruthy()
    it 'should add widget with correct options and initFn', ->
      expect( Linc._functions.widgetA.init ).toBe a_fn
      expect( Linc._functions.widgetB.init ).toBe b_fn
      expect( Linc._functions.widgetA.options.once ).toBeFalsy()
      expect( Linc._functions.widgetB.options.once ).toBeTruthy()

  describe 'widgets with single scope', ->
    Linc.add 'widgetX.scopeA', a_fn
    Linc.add 'widgetY.scopeB', b_fn
    Linc.add 'widgetZ.scopeA', { once : true }, a_fn
    
    it 'should not add widget to root namespace in fn store', ->
      expect( Linc._functions.widgetX ).toBeFalsy()
      expect( Linc._functions.widgetY ).toBeFalsy()
      expect( Linc._functions.widgetZ ).toBeFalsy()
    it 'should add widget to namespace in fn store', ->
      expect( Linc._functions.scopeA.widgetX.init ).toBe a_fn
      expect( Linc._functions.scopeB.widgetY.init ).toBe b_fn
      expect( Linc._functions.scopeA.widgetZ.init ).toBeTruthy()
      expect( Linc._functions.scopeA.widgetZ.options.once ).toBeTruthy()

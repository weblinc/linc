linc
====

js execution controller for the browser or node.js

Installation
====
`npm install linc` or include `linc.js` on your page

API
====

`Linc.add( name, [ options ], fn )` Adds a widget with string `name`, optional options `object`, and run function `fn`. Widgets can be scoped by adding period separated namespaces in the name, ex:
  * `validation.signup` Add the validation widget to the signup namespace
  * `validation.signup.signin` Add the validation widget to both signup and signin namespaces

`Linc.run( context, [ options ] )` Executes all functions with `context`, optionally passing an options object.

Widget Options
====
* `once` This widget is only called once during its life

Run Options
====
* `context` Each widget's associated function is called with `this` as `context`
* `namespace` Calls all widgets that are within `namespace`, as well as unnamespaced widgets. Can be a namespace string, or an array of strings for multiple namespaces.
* `all` Calls all widgets, namespaced and unscoped.

Examples
====

```javascript
  // Adds a validation widget that can only be called once.
  Linc.add( 'validation', { once: true }, function () {
    // ...
  });

  // Adds the register widget to the account namespace
  Linc.add( 'register.account', function () {
    // ...
  });

  // Runs all unscoped widgets -- just 'validation' in this case
  Linc.run();

  // Runs all unscoped and widgets in the namespace 'account' --
  // both 'register' and 'validation' functions are executed with 'document' as context
  Linc.run({ context: document, namespace: 'account' } );
```

Development
====

Uses jasmine-node for running specs, and coffeescript for source -- run `make` in project root to compile and run specs.

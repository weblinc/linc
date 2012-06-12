(function() {
  var Linc, isArray, isFunction, isObject, _ref;
  var __hasProp = Object.prototype.hasOwnProperty;

  Linc = {};

  Linc._functions = {};

  Linc.add = function() {
    var functions, initFn, name, ns, nsNames, options, register, _i, _len, _results;
    name = arguments[0];
    options = {};
    initFn = arguments[arguments.length - 1];
    functions = this._functions;
    if (isObject(arguments[1])) options = arguments[1];
    register = function(ns) {
      var funcs, _ref;
      funcs = ns ? (_ref = functions[ns]) != null ? _ref : functions[ns] = {} : functions;
      return funcs[name] = {
        options: options,
        init: initFn
      };
    };
    if (~name.indexOf('.')) {
      nsNames = name.split('.');
      name = nsNames.shift();
      _results = [];
      for (_i = 0, _len = nsNames.length; _i < _len; _i++) {
        ns = nsNames[_i];
        _results.push(register(ns));
      }
      return _results;
    } else {
      return register();
    }
  };

  Linc.run = function(o) {
    var all, key, namespaces, ns, runFuncs, scope, _i, _len, _ref, _ref2;
    if (o == null) o = {};
    scope = (_ref = o.scope) != null ? _ref : document;
    ns = (_ref2 = o.namespace) != null ? _ref2 : [];
    all = o.all;
    if (all) {
      ns = (function() {
        var _ref3, _results;
        _ref3 = this._functions;
        _results = [];
        for (key in _ref3) {
          if (!__hasProp.call(_ref3, key)) continue;
          if (isObject(key)) _results.push(key);
        }
        return _results;
      }).call(this);
    } else {
      ns = isArray(ns) ? ns : [ns];
    }
    for (_i = 0, _len = ns.length; _i < _len; _i++) {
      namespaces = ns[_i];
      runFuncs(namespaces);
    }
    runFuncs();
    return runFuncs = function(namespace) {
      var funcs, name, widget, _ref3, _results;
      funcs = (_ref3 = this._functions[namespace]) != null ? _ref3 : this._functions;
      _results = [];
      for (name in funcs) {
        if (!__hasProp.call(funcs, name)) continue;
        widget = funcs[name];
        if (!(widget.options.once && widget.called)) {
          widget.init.call(scope);
          _results.push(widget.called = true);
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };
  };

  if (typeof module !== "undefined" && module !== null) {
    module.exports = Linc;
  } else {
    this.Linc = Linc;
  }

  isArray = (_ref = Array.isArray) != null ? _ref : function(o) {
    return Object.prototype.toString.call(o) === '[object Array]';
  };

  isFunction = function(o) {
    return Object.prototype.toString.call(o) === '[object Function]';
  };

  isObject = function(o) {
    return o === Object(o);
  };

}).call(this);

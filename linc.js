(function() {
  var Linc, isArray, isFunction, isObject, root, _ref,
    __hasProp = Object.prototype.hasOwnProperty;

  root = this;

  Linc = (typeof exports !== "undefined" && exports !== null) && this || (this.Linc = {});

  Linc._functions = {};

  Linc._defaults = {
    namespace: '',
    context: root
  };

  Linc.add = function() {
    var initFn, name, ns, nsNames, widget, _base, _i, _len, _results;
    name = arguments[0];
    initFn = arguments[arguments.length - 1];
    nsNames = [];
    widget = {
      options: isObject(arguments[1]) ? arguments[1] : {},
      init: initFn
    };
    if (~name.indexOf('.')) {
      nsNames = name.split('.');
      name = nsNames.shift();
    } else if (this._defaults.namespace) {
      nsNames = this._defaults.namespace.split('.');
    }
    if (nsNames.length) {
      _results = [];
      for (_i = 0, _len = nsNames.length; _i < _len; _i++) {
        ns = nsNames[_i];
        if ((_base = this._functions)[ns] == null) _base[ns] = {};
        _results.push(this._functions[ns][name] = widget);
      }
      return _results;
    } else {
      return this._functions[name] = widget;
    }
  };

  Linc.run = function(o) {
    var all, context, funcs, name, namespace, ns, widget, _i, _len, _ref, _ref2, _ref3, _results;
    if (o == null) o = {};
    context = (_ref = o.context) != null ? _ref : this._defaults.context;
    namespace = (_ref2 = o.namespace) != null ? _ref2 : this._defaults.namespace;
    all = o.all;
    if (all) {
      namespace = (function() {
        var _ref3, _results;
        _ref3 = this._functions;
        _results = [];
        for (name in _ref3) {
          if (!__hasProp.call(_ref3, name)) continue;
          namespace = _ref3[name];
          if (!isFunction(namespace.init)) _results.push(name);
        }
        return _results;
      }).call(this);
    } else {
      namespace = isArray(namespace) ? namespace : [namespace];
    }
    namespace.push(null);
    _results = [];
    for (_i = 0, _len = namespace.length; _i < _len; _i++) {
      ns = namespace[_i];
      funcs = (_ref3 = this._functions[ns]) != null ? _ref3 : this._functions;
      _results.push((function() {
        var _results2;
        _results2 = [];
        for (name in funcs) {
          if (!__hasProp.call(funcs, name)) continue;
          widget = funcs[name];
          if (isFunction(widget.init)) {
            if (!(widget.options.once && widget.called)) {
              widget.init.call(context);
              _results2.push(widget.called = true);
            } else {
              _results2.push(void 0);
            }
          }
        }
        return _results2;
      })());
    }
    return _results;
  };

  Linc.setDefaults = function(o) {
    var option, value;
    for (option in o) {
      if (!__hasProp.call(o, option)) continue;
      value = o[option];
      this._defaults[option] = value;
    }
    return this._defaults;
  };

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

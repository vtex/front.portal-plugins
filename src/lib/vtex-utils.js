(function() {
  var Utils, root, utils,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __slice = [].slice;

  Utils = (function() {
    function Utils() {
      this._extend = __bind(this._extend, this);
      this._getThousandsSeparator = __bind(this._getThousandsSeparator, this);
      this._getDecimalSeparator = __bind(this._getDecimalSeparator, this);
      this._getCurrencySymbol = __bind(this._getCurrencySymbol, this);
      this.mapObj = __bind(this.mapObj, this);
      this.hash = __bind(this.hash, this);
      this.spacesToHyphens = __bind(this.spacesToHyphens, this);
      this.sanitize = __bind(this.sanitize, this);
      this.plainChars = __bind(this.plainChars, this);
      this.maskInfo = __bind(this.maskInfo, this);
      this.maskString = __bind(this.maskString, this);
      this.capitalizeSentence = __bind(this.capitalizeSentence, this);
      this.capitalize = __bind(this.capitalize, this);
      this.capitalizeWord = __bind(this.capitalizeWord, this);
      this.dateFromISO8601 = __bind(this.dateFromISO8601, this);
      this.urlParams = __bind(this.urlParams, this);
      this.getCookieValue = __bind(this.getCookieValue, this);
      this.readCookie = __bind(this.readCookie, this);
      this.pad = __bind(this.pad, this);
      this.intAsCurrency = __bind(this.intAsCurrency, this);
      this.formatCurrency = __bind(this.formatCurrency, this);
    }

    /*
    	Formats monetary value as a string with decimal and thousands separators
    
     @param [Number] value the value to format
     @param [Object] options
     @option options [String] decimalSeparator the character used to separate the decimal and integer parts. Default: ','
     @option options [String] thousandsSeparator the character used to separate the thousands. Default: '.'
     @option options [Boolean] absolute whether to use an absolute value or not. Default: false
     @option options [Integer] decimalPlaces the number of decimal places to use. Default: 2
     @return [String] the value formatted according to the options given
    
     @example Default usage
     	formatCurrency(1050)
     	#=> '1.050,00'
    
     @example Usage with options
     	formatCurrency(-1050.99, {'decimalSeparator': '.', 'thousandsSeparator': ',', 'absolute': true, 'decimalPlaces': 3}
     	#=> '1,050.990'
    */


    Utils.prototype.formatCurrency = function(value, options) {
      var decimalPart, defaults, opts, wholePart, _ref;
      defaults = {
        decimalSeparator: this._getDecimalSeparator(),
        thousandsSeparator: this._getThousandsSeparator(),
        absolute: false,
        decimalPlaces: 2
      };
      opts = this._extend(defaults, options);
      if (opts.absolute && value < 0) {
        value = -value;
      }
      value = value.toFixed(opts.decimalPlaces);
      _ref = value.split('.'), wholePart = _ref[0], decimalPart = _ref[1];
      wholePart = wholePart.replace(/\B(?=(\d{3})+(?!\d))/g, opts.thousandsSeparator);
      return wholePart + opts.decimalSeparator + decimalPart;
    };

    Utils.prototype.intAsCurrency = function(value, options) {
      return (options.currencySymbol || this._getCurrencySymbol()) + utils.formatCurrency(value / 100, options);
    };

    /*
     Pads a string until it reaches a certain length. Non-strings will be converted.
    
     @param [String] str the string to be padded. Any other type will be converted to string
     @param [Integer] max the length desired
    	@param [Object] options
     @option options [String] char the character used to pad the string. Default: '0'
     @option options [String] position where to pad. Valid: 'left', 'right'. Default: 'left'
     @return [String] the string padded according to the options given
    
     @example Default usage
     	pad('19,99', 6)
     	#=> '019,99'
    
     @example Usage with options
     	pad('Hello', 7, {'char': ' ', 'position': 'right'})
     	#=> 'Hello  '
    */


    Utils.prototype.pad = function(str, max, options) {
      var defaults, opts, toadd;
      defaults = {
        char: '0',
        position: 'left'
      };
      opts = this._extend(defaults, options);
      opts.char = opts.char.charAt(0);
      str = str + '';
      toadd = Array(max - str.length + 1).join(opts.char);
      if (opts.position === 'right') {
        return str + toadd;
      } else {
        return toadd + str;
      }
    };

    /*
    	Returns the content of the cooke with the given name
    
     @param [String] name the name of the cookie to be read
     @return [String] the content of the cookie with the given name
    
     @example Default usage
     	# Assuming document.cookie is 'a=123; b=xyz'
     	readCookie(a)
     	#=> '123'
     	readCookie(b)
     	#=> 'xyz'
    */


    Utils.prototype.readCookie = function(name) {
      var ARRcookies, key, pair, value, _i, _len;
      ARRcookies = document.cookie.split(";");
      for (_i = 0, _len = ARRcookies.length; _i < _len; _i++) {
        pair = ARRcookies[_i];
        key = pair.substr(0, pair.indexOf("=")).replace(/^\s+|\s+$/g, "");
        value = pair.substr(pair.indexOf("=") + 1);
        if (key === name) {
          return unescape(value);
        }
      }
    };

    /*
     Receives a cookie that has "subcookies" in the format a=b&c=d
    	Returns the content of the "subcookie" with the given name
    
     @param [String] cookie a string with "subcookies" in the format 'a=b&c=d'
     @param [String] name the name of the "subcookie" to get the value of
     @return [String] the content of the "subcookie" with the given name
    
     @example Get subcookies
     	c = readCookie('sub')
     	#=> 'a=b&c=d'
     	getCookieValue(c, 'a')
     	#=> 'b'
     	getCookieValue(c, 'c')
     	#=> 'd'
    */


    Utils.prototype.getCookieValue = function(cookie, name) {
      var key, subcookie, subcookies, value, _i, _len;
      subcookies = cookie.split("&");
      for (_i = 0, _len = subcookies.length; _i < _len; _i++) {
        subcookie = subcookies[_i];
        key = subcookie.substr(0, subcookie.indexOf("="));
        value = subcookie.substr(subcookie.indexOf("=") + 1);
        if (key === name) {
          return unescape(value);
        }
      }
    };

    /*
     Parses the querystring and returns its object representation.
     It decodes URI components (such as %3D to =) and replaces + with space.
    
     @return [Object] an object representation of the querystring parameters
    
     @example
     	# URL is http://google.com/?a=b&c=hello+%3D+hi
     	urlParam()
     	#=> {'a': 'b', 'c': 'hello = hi'}
    */


    Utils.prototype.urlParams = function() {
      var decode, match, params, plus, query, search;
      params = {};
      search = /([^&=]+)=?([^&]*)/g;
      plus = /\+/g;
      decode = function(s) {
        return decodeURIComponent(s.replace(plus, " "));
      };
      query = window.location.search.substring(1);
      while (match = search.exec(query)) {
        params[decode(match[1])] = decode(match[2]);
      }
      return params;
    };

    /*
     Transforms a ISO8061 compliant date string into a Date object
    
     @param [String] isostr a string in the format YYYY-MM-DDThh:mm:ss
     @return [Date] a Date object created from the date information in the string
    
     @example Default usage
     	dateFromISO8601('1997-07-16T19:20:30')
     	#=> Date object ("Thu Jul 18 2013 15:08:08 GMT-0300 (BRT)")
    */


    Utils.prototype.dateFromISO8601 = function(isostr) {
      var part1, parts;
      parts = isostr.match(/\d+/g);
      part1 = parts[1] - 1;
      return new Date(parts[0], part1, parts[2], parts[3], parts[4], parts[5]);
    };

    /*
     Capitalizes the first character of a given string.
    
     @param [String] word the word to be capitalized
     @return [String] the capitalized word
    
     @example Default usage
     	capitalizeWord('hello')
     	#=> 'Hello'
    
     @example It only capitalizes the first character
     	capitalizeWord(' hi ')
     	#=> ' hi '
    */


    Utils.prototype.capitalizeWord = function(word) {
      if (word == null) {
        word = '';
      }
      return word.charAt(0).toUpperCase() + word.slice(1);
    };

    /*
     @see {Utils#capitalizeWord}.
    */


    Utils.prototype.capitalize = function(word) {
      if (word == null) {
        word = '';
      }
      return capitalizeWord(word);
    };

    /*
     Capitalizes each word in a given sentende.
    
     @param [String] sentence the sentence to be capitalized
     @return [String] the capitalized sentence
    
     @example Default usage
     	capitalizeSentence('* hello world!')
     	#=> '* Hello Wordl!'
    */


    Utils.prototype.capitalizeSentence = function(sentence) {
      var newWords, oldWords, word;
      if (sentence == null) {
        sentence = '';
      }
      oldWords = sentence.toLowerCase().split(' ');
      newWords = (function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = oldWords.length; _i < _len; _i++) {
          word = oldWords[_i];
          _results.push(this.capitalizeWord(word));
        }
        return _results;
      }).call(this);
      return newWords.join(' ');
    };

    Utils.prototype.maskString = function(str, mask) {
      var applyMask, argString, fixedCharsReg, maskStr;
      maskStr = mask.mask || mask;
      applyMask = function(valueArray, maskArray, fixedCharsReg) {
        var i, _i, _ref;
        for (i = _i = 0, _ref = valueArray.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
          if (maskArray[i] && fixedCharsReg.test(maskArray[i]) && maskArray[i] !== valueArray[i]) {
            valueArray.splice(i, 0, maskArray[i]);
          }
        }
        return valueArray;
      };
      argString = typeof str === "string" ? str : String(str);
      fixedCharsReg = new RegExp('[(),.:/ -]');
      return applyMask(argString.split(""), maskStr.split(""), fixedCharsReg).join("").substring(0, maskStr.split("").length);
    };

    /*
     Substitutes each * in a string with span.masked-info *
    
     @param [String] info the string to mask
     @return [String] the masked string
    
     @example Default usage
     	maskInfo('abc**')
     	#=> 'abc<span class="masked-info">*</span><span class="masked-info">*</span>'
    */


    Utils.prototype.maskInfo = function(info) {
      var maskRegex, maskText;
      maskRegex = /\*/g;
      maskText = '<span class="masked-info">*</span>';
      if (info) {
        return info.replace(maskRegex, maskText);
      } else {
        return info;
      }
    };

    Utils.prototype.plainChars = function(str) {
      var plain, regex, specialChars;
      if (str == null) {
        return;
      }
      specialChars = "ąàáäâãåæćęèéëêìíïîłńòóöôõøśùúüûñçżź";
      plain = "aaaaaaaaceeeeeiiiilnoooooosuuuunczz";
      regex = new RegExp("[" + specialChars + "]", 'g');
      str += "";
      return str.replace(regex, function(char) {
        return plain.charAt(specialChars.indexOf(char));
      });
    };

    Utils.prototype.sanitize = function(str) {
      return this.plainChars(str.replace(/\s/g, '').replace(/\/|\\/g, '-').replace(/\(|\)|\'|\"/g, '').toLowerCase().replace(/\,/g, 'V').replace(/\./g, 'P'));
    };

    /*
    	Replaces all space charactes with hyphen characters
    
     @param [String] str the string
     @return [Stirng] the string with all space characters replaced with hyphen characters
    
     @example
     	spacesToHyphens("Branco e Preto")
     	#=> "Branco-e-Preto"
    */


    Utils.prototype.spacesToHyphens = function(str) {
      return str.replace(/\ /g, '-');
    };

    /*
     Creates a (mostly) unique hashcode from a string
    
     @param [String] str the string
     @return [Number] the created hashcode
    
     @example Typical usage is to give an object a unique ID
     	uid = hash(Date.now())
     	#=> -707575924
    */


    Utils.prototype.hash = function(str) {
      var char, charcode, hashed, _i, _len;
      hashed = 0;
      for (_i = 0, _len = str.length; _i < _len; _i++) {
        char = str[_i];
        charcode = char.charCodeAt(0);
        hashed = ((hashed << 5) - hashed) + charcode;
        hashed = hashed & hashed;
      }
      return hashed;
    };

    /*
    	Produces a new object mapping each key:value pair to a key:f(value) pair.
    
     @param [Object] obj the object
     @param [Function] f a function that will receive (key, value) and should return a replacement value
     @return [Object] a new object with each value mapped according to the function
    
     @example
     	obj = {a: 1, b: 2};
     	mapObj(obj, function(key, value){
     		return value*10
     	});
     	#=> {a: 10, b: 20}
    */


    Utils.prototype.mapObj = function(obj, f) {
      var k, obj2, v;
      obj2 = {};
      for (k in obj) {
        if (!__hasProp.call(obj, k)) continue;
        v = obj[k];
        obj2[k] = f(k, v);
      }
      return obj2;
    };

    Utils.prototype._getCurrencySymbol = function() {
      var _ref, _ref1;
      return ((_ref = window.vtex) != null ? (_ref1 = _ref.i18n) != null ? _ref1.getCurrencySymbol() : void 0 : void 0) || 'R$ ';
    };

    Utils.prototype._getDecimalSeparator = function() {
      var _ref, _ref1;
      return ((_ref = window.vtex) != null ? (_ref1 = _ref.i18n) != null ? _ref1.getDecimalSeparator() : void 0 : void 0) || ',';
    };

    Utils.prototype._getThousandsSeparator = function() {
      var _ref, _ref1;
      return ((_ref = window.vtex) != null ? (_ref1 = _ref.i18n) != null ? _ref1.getThousandsSeparator() : void 0 : void 0) || '.';
    };

    Utils.prototype._extend = function() {
      var obj, prop, source, sources, _i, _len;
      obj = arguments[0], sources = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      for (_i = 0, _len = sources.length; _i < _len; _i++) {
        source = sources[_i];
        if (source) {
          for (prop in source) {
            obj[prop] = source[prop];
          }
        }
      }
      return obj;
    };

    return Utils;

  })();

  utils = new Utils();

  root = typeof exports !== "undefined" && exports !== null ? exports : window;

  if (root._ != null) {
    root._.mixin(utils);
  } else {
    root._ = utils;
    root._.extend = utils._extend;
  }

}).call(this);

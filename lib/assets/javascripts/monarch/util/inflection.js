(function(_) {
  var rules = {
    plural:  [
      [/(quiz)$/i,               "$1zes"  ],
      [/^(ox)$/i,                "$1en"   ],
      [/([m|l])ouse$/i,          "$1ice"  ],
      [/(matr|vert|ind)ix|ex$/i, "$1ices" ],
      [/(x|ch|ss|sh)$/i,         "$1es"   ],
      [/([^aeiouy]|qu)y$/i,      "$1ies"  ],
      [/(hive)$/i,               "$1s"    ],
      [/(?:([^f])fe|([lr])f)$/i, "$1$2ves"],
      [/sis$/i,                  "ses"    ],
      [/([ti])um$/i,             "$1a"    ],
      [/(buffal|tomat)o$/i,      "$1oes"  ],
      [/(bu)s$/i,                "$1ses"  ],
      [/(alias|status)$/i,       "$1es"   ],
      [/(octop|vir)us$/i,        "$1i"    ],
      [/(ax|test)is$/i,          "$1es"   ],
      [/s$/i,                    "s"      ],
      [/$/,                      "s"      ]
    ],

    singular: [
      [/(quiz)zes$/i,                                                    "$1"     ],
      [/(matr)ices$/i,                                                   "$1ix"   ],
      [/(vert|ind)ices$/i,                                               "$1ex"   ],
      [/^(ox)en/i,                                                       "$1"     ],
      [/(alias|status)es$/i,                                             "$1"     ],
      [/(octop|vir)i$/i,                                                 "$1us"   ],
      [/(cris|ax|test)es$/i,                                             "$1is"   ],
      [/(shoe)s$/i,                                                      "$1"     ],
      [/(o)es$/i,                                                        "$1"     ],
      [/(bus)es$/i,                                                      "$1"     ],
      [/([m|l])ice$/i,                                                   "$1ouse" ],
      [/(x|ch|ss|sh)es$/i,                                               "$1"     ],
      [/(m)ovies$/i,                                                     "$1ovie" ],
      [/(s)eries$/i,                                                     "$1eries"],
      [/([^aeiouy]|qu)ies$/i,                                            "$1y"    ],
      [/([lr])ves$/i,                                                    "$1f"    ],
      [/(tive)s$/i,                                                      "$1"     ],
      [/(hive)s$/i,                                                      "$1"     ],
      [/([^f])ves$/i,                                                    "$1fe"   ],
      [/(^analy)ses$/i,                                                  "$1sis"  ],
      [/((a)naly|(b)a|(d)iagno|(p)arenthe|(p)rogno|(s)ynop|(t)he)ses$/i, "$1$2sis"],
      [/([ti])a$/i,                                                      "$1um"   ],
      [/(n)ews$/i,                                                       "$1ews"  ],
      [/s$/i,                                                            ""       ]
    ],

    irregular: [
      ['move',   'moves'   ],
      ['sex',    'sexes'   ],
      ['child',  'children'],
      ['man',    'men'     ],
      ['person', 'people'  ]
    ],

    uncountable: [
      "sheep",
      "fish",
      "series",
      "species",
      "money",
      "rice",
      "information",
      "equipment"
    ]
  };

  _.mixin({
    pluralize: function(word) {
      for (var i = 0; i < rules.uncountable.length; i++) {
        var uncountable = rules.uncountable[i];
        if (word.toLowerCase() == uncountable) {
          return uncountable;
        }
      }
      for (var i = 0; i < rules.irregular.length; i++) {
        var singular = rules.irregular[i][0];
        var plural   = rules.irregular[i][1];
        if ((word.toLowerCase() == singular) || (word == plural)) {
          return plural;
        }
      }
      for (var i = 0; i < rules.plural.length; i++) {
        var regex          = rules.plural[i][0];
        var replaceString = rules.plural[i][1];
        if (regex.test(word)) {
          return word.replace(regex, replaceString);
        }
      }
    },

    singularize: function(word) {
      for (var i = 0; i < rules.uncountable.length; i++) {
        var uncountable = rules.uncountable[i];
        if (word.toLowerCase() == uncountable) {
          return uncountable;
        }
      }
      for (var i = 0; i < rules.irregular.length; i++) {
        var singular = rules.irregular[i][0];
        var plural   = rules.irregular[i][1];
        if ((word.toLowerCase() == singular) || (word == plural)) {
          return plural;
        }
      }
      for (var i = 0; i < rules.singular.length; i++) {
        var regex          = rules.singular[i][0];
        var replaceString = rules.singular[i][1];
        if (regex.test(word)) {
          return word.replace(regex, replaceString);
        }
      }
    },

    underscore: function(word) {
      return word.replace(/([a-zA-Z\d])([A-Z])/g,'$1_$2').toLowerCase();
    },

    underscoreAndPluralize: function(word) {
      return this.underscore(this.pluralize(word));
    },

    camelize: function(word, lowFirstLetter) {
      var parts = word.split('_'), len = parts.length;
      var camelized = "";
      for (var i = 0; i < len; i++) {
        var firstLetter = (lowFirstLetter && i == 0) ? parts[i].charAt(0) : parts[i].charAt(0).toUpperCase();
        camelized += firstLetter + parts[i].substring(1);
      }
      return camelized;
    },

    underscoreKeys: function(hash) {
      var newHash = {};
      _.each(hash, function(value, key) {
        newHash[_.underscore(key)] = value;
      });
      return newHash;
    },

    camelizeKeys: function(hash) {
      var newHash = {};
      _.each(hash, function(value, key) {
        newHash[_.camelize(key, true)] = value;
      });
      return newHash;
    },

    capitalize: function(word) {
      return word.charAt(0).toUpperCase() + word.substr(1);
    },

    uncapitalize: function(word) {
      return word.charAt(0).toLowerCase() + word.substr(1);
    }
  });
})(_);

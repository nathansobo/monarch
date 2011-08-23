(function(Monarch) {
  Monarch.Errors = new JS.Class('Monarch.Errors', {
    initialize: function() {
      this.errorsByField = {};
    },

    add: function(name, error) {
      if (!this.errorsByField[name]) this.errorsByField[name] = [];
      this.errorsByField[name].push(error);
    },

    on: function(name) {
      return this.errorsByField[name] || [];
    },

    assign: function(errorsByField) {
      this.errorsByField = errorsByField;
    },

    isEmpty: function() {
      return _.isEmpty(this.errorsByField);
    },

    clear: function(name) {
      delete this.errorsByField[name];
    }
  });
})(Monarch);

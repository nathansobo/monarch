JS.Class.include({
  deriveEquality: function() {
    var properties = _.toArray(arguments);
    var length = properties.length;

    this.define('isEqual', function(other) {
      if (!other || this.klass !== other.klass) return false;
      for (var i = 0; i < length; i++) {
        if (!_.isEqual(this[properties[i]], other[properties[i]])) return false;
      }
      return true;
    });
  }
})
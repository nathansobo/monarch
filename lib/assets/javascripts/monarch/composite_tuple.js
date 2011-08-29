(function(Monarch) {
  Monarch.CompositeTuple = new JS.Class('Monarch.CompositeTuple', {
    initialize: function(left, right) {
      this.left = left;
      this.right = right;
    },

    getField: function(name) {
      return this.left.getField(name) || this.right.getField(name);
    },

    getFieldValue: function(name) {
      return this.getField(name).getValue();
    },

    getRecord: function(tableName) {
      return this.left.getRecord(tableName) || this.right.getRecord(tableName);
    },

    toString: function() {
      return "<" + this.klass.displayName + " left:" + this.left.toString() + " right:" + this.right.toString() + ">";
    }
  });
})(Monarch);

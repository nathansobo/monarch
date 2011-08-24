(function(Monarch) {
  Monarch.Relations.Relation = new JS.Class('Monarch.Relations.Relation', {
    initialize: function() {
      this._contents = new Monarch.Util.SkipList(this._buildComparator());
    },

    insert: function(tuple) {
      return this._contents.insert(tuple);
    },

    remove: function(tuple) {
      return this._contents.remove(tuple);
    },

    contains: function(tuple) {
      return this._contents.indexOf(tuple) !== -1;
    },

    _buildComparator: function() {
      // null is treated like infinity
      function lessThan(a, b) {
        if ((a === null || a === undefined) && b !== null && b !== undefined) return false;
        if ((b === null || b === undefined) && a !== null && a !== undefined) return true;
        return a < b;
      }

      return function(a, b) {
        if (lessThan(a, b)) return -1;
        if (lessThan(b, a)) return 1;
        return 0;
      }
    }
  });
})(Monarch);

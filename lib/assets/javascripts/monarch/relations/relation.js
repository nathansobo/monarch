(function(Monarch) {
  Monarch.Relations.Relation = new JS.Class('Monarch.Relations.Relation', {
    initialize: function() {
      this._contents = new Monarch.Util.SkipList(this._buildComparator());
      this._insertNode = new Monarch.Util.Node();
      this._updateNode = new Monarch.Util.Node();
      this._removeNode = new Monarch.Util.Node();
    },

    insert: function(tuple) {
      this._contents.insert(tuple);
      this._insertNode.publish(tuple);
    },

    tupleUpdated: function(tuple, changeset) {
      this._updateNode.publish(tuple, changeset);
    },

    remove: function(tuple) {
      this._contents.remove(tuple);
      this._removeNode.publish(tuple);
    },

    contains: function(tuple) {
      return this._contents.indexOf(tuple) !== -1;
    },

    onInsert: function(callback, context) {
      return this._insertNode.subscribe(callback, context);
    },

    onUpdate: function(callback, context) {
      return this._updateNode.subscribe(callback, context);
    },

    onRemove: function(callback, context) {
      return this._removeNode.subscribe(callback, context);
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

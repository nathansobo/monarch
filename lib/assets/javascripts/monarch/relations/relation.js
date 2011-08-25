(function(Monarch) {
  Monarch.Relations.Relation = new JS.Class('Monarch.Relations.Relation', {
    initialize: function() {
      this._insertNode = new Monarch.Util.Node();
      this._updateNode = new Monarch.Util.Node();
      this._removeNode = new Monarch.Util.Node();
    },

    contents: function() {
      if (this.isActive) {
        if (!this._contents) this._contents = this.buildContents();
        return this._contents;
      } else {
        return this.buildContents();
      }
    },

    insert: function(tuple) {
      var index = this.contents().insert(this.buildKey(tuple), tuple);
      this._insertNode.publish(tuple, index);
    },

    tupleUpdated: function(tuple, changeset, newKey, oldKey) {
      var oldIndex = this.contents().remove(oldKey);
      var newIndex = this.contents().insert(newKey, tuple);
      this._updateNode.publish(tuple, changeset, newIndex, oldIndex);
    },

    remove: function(tuple) {
      var index = this.contents().remove(this.buildKey(tuple));
      this._removeNode.publish(tuple, index);
    },

    contains: function(tuple) {
      return this.indexOf(tuple) !== -1;
    },

    indexOf: function(tuple) {
      return this.contents().indexOf(this.buildKey(tuple));
    },

    at: function(index) {
      return this.contents().at(index);
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

    each: function(iterator, context) {
      _.each(this.all(), iterator, context);
    },

    where: function(predicate) {
      return new Monarch.Relations.Selection(this, predicate);
    },

    buildContents: function() {
      var contents = new Monarch.Util.SkipList(this.buildComparator());
      this.each(function(tuple) {
        contents.insert(this.buildKey(tuple), tuple);
      }, this);
      return contents;
    },

    buildComparator: function() {
      // null is treated like infinity
      function lessThan(a, b) {
        if ((a === null || a === undefined) && b !== null && b !== undefined) return false;
        if ((b === null || b === undefined) && a !== null && a !== undefined) return true;
        return a < b;
      }

      var orderByExpressions = this.orderByExpressions;
      var length = orderByExpressions.length;

      return function(a, b) {
        for(var i = 0; i < length; i++) {
          var orderByExpression = orderByExpressions[i]
          var columnName = orderByExpression.columnName;
          var directionCoefficient = orderByExpression.directionCoefficient;

          var aValue = a[columnName];
          var bValue = b[columnName];

          if (lessThan(aValue, bValue)) return -1 * directionCoefficient;
          else if (lessThan(bValue, aValue)) return 1 * directionCoefficient;
        }
        return 0;
      };
    },

    buildKey: function(tuple) {
      var key = {};
      _.each(this.orderByExpressions, function(orderByExpression) {
        var columnName = orderByExpression.columnName;
        key[columnName] = tuple.getFieldValue(columnName);
      });
      return key;
    },

    resolvePredicate: function(object) {
      if (_.isFunction(object.isA) && object.isA(Monarch.Expressions.Predicate)) {
        return object.resolve(this);
      }

      var predicates = _.map(object, function(value, key) {
        return new Monarch.Expressions.Equal(key, value).resolve(this);
      }, this);

      return _.inject(predicates, function(left, right) {
        return left.and(right);
      });
    }
  });
})(Monarch);

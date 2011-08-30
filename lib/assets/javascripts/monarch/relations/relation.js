(function(Monarch) {
  Monarch.Relations.Relation = new JS.Class('Monarch.Relations.Relation', {
    include: JS.Enumerable,
    
    contents: function() {
      if (this.isActive) {
        if (!this._contents) this._contents = this.buildContents();
        return this._contents;
      } else {
        return this.buildContents();
      }
    },

    insert: function(tuple, newKey, oldKey) {
      if (!newKey) newKey = this.buildKey(tuple);
      var index = this.contents().insert(newKey, tuple);
      this._insertNode.publish(tuple, index, newKey, oldKey || newKey);
    },

    tupleUpdated: function(tuple, changeset, newKey, oldKey) {
      var oldIndex = this.contents().remove(oldKey);
      var newIndex = this.contents().insert(newKey, tuple);
      this._updateNode.publish(tuple, changeset, newIndex, oldIndex, newKey, oldKey);
    },

    remove: function(tuple, newKey, oldKey) {
      if (newKey && !oldKey) throw new Error("need to pass 2 keys");
      if (!newKey) newKey = oldKey = this.buildKey(tuple);
      var index = this.contents().remove(oldKey);
      this._removeNode.publish(tuple, index, newKey, oldKey);
    },

    contains: function(tuple) {
      return this.indexOf(tuple) !== -1;
    },

    indexOf: function(tuple) {
      return this.contents().indexOf(this.buildKey(tuple));
    },

    containsKey: function(key) {
      return this.contents().indexOf(key) !== -1;
    },

    findByKey: function(key) {
      return this.contents().find(key);
    },

    at: function(index) {
      return this.contents().at(index);
    },

    onInsert: function(callback, context) {
      this.activate();
      return this._insertNode.subscribe(callback, context);
    },

    onUpdate: function(callback, context) {
      this.activate();
      return this._updateNode.subscribe(callback, context);
    },

    onRemove: function(callback, context) {
      this.activate();
      return this._removeNode.subscribe(callback, context);
    },

    forEach: function(iterator, context) {
      _.each(this.all(), iterator, context);
    },

    where: function(predicate) {
      return new Monarch.Relations.Selection(this, predicate);
    },

    join: function(right, predicate) {
      return new Monarch.Relations.InnerJoin(this, right, predicate);
    },

    project: function(table) {
      return new Monarch.Relations.Projection(this, table);
    },

    joinThrough: function(table) {
      return this.join(table).project(table);
    },

    union: function(right) {
      return new Monarch.Relations.Union(this, right);
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
    },

    activate: function() {
      if (this.isActive) return;
      this._activate();
    },

    _activate: function() {
      this._insertNode = new Monarch.Util.Node();
      this._updateNode = new Monarch.Util.Node();
      this._removeNode = new Monarch.Util.Node();
      this._insertNode.onEmpty(this.method('deactivateIfNeeded'));
      this._updateNode.onEmpty(this.method('deactivateIfNeeded'));
      this._removeNode.onEmpty(this.method('deactivateIfNeeded'));
      this.subscriptions = new Monarch.Util.SubscriptionBundle();
      this.isActive = true;
      this.contents(); // cause contents to memoize
    },

    deactivateIfNeeded: function() {
      if (!this.hasSubscriptions()) this.deactivate();
    },

    deactivate: function() {
      delete this._insertNode;
      delete this._updateNode;
      delete this._removeNode;
      this.subscriptions.destroy();
      this.isActive = false;
    },

    subscribe: function(operand, event, callback) {
      this.subscriptions.add(operand[event](callback, this));
    },

    subscriptionCount: function() {
      return this._insertNode.size() + this._updateNode.size() + this._removeNode.size();
    },
    
    hasSubscriptions: function() {
      return this.subscriptionCount() > 0;
    }
  });

  Monarch.Relations.Relation.alias({'each': 'forEach'});
})(Monarch);

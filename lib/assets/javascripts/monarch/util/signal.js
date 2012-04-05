(function(Monarch) {
  Monarch.Util.Signal = new JS.Class('Monarch.Util.Signal', {
    initialize: function(sources, transformer) {
      if (!_.isArray(sources)) sources = [sources];
      this.sources = sources;

      this.transformer = transformer || function() {
        return _.toArray(arguments).join(' ');
      };

      this.changeNode = new Monarch.Util.Node();
      _.each(this.sources, this.method('subscribeToSource'));
    },

    subscribeToSource: function(source, index) {
      source.onChange(function(newValue, oldValue) {
        var newSourceValues = this.getSourceValues();
        var oldSourceValues = _.clone(newSourceValues);
        oldSourceValues[index] = oldValue;
        this.publishChange(newSourceValues, oldSourceValues);
      }, this);
    },

    publishChange: function(newSourceValues, oldSourceValues) {
      var newValue = this.transformer.apply(null, newSourceValues);
      var oldValue = this.transformer.apply(null, oldSourceValues);
      this.changeNode.publish(newValue, oldValue);
    },

    getValue: function() {
      return this.transformer.apply(null, this.getSourceValues());
    },

    getSourceValues: function() {
      return _.map(this.sources, function(source) {
        return source.getValue();
      });
    },

    onChange: function(callback, context) {
      return this.changeNode.subscribe(callback, context);
    }
  });
})(Monarch);

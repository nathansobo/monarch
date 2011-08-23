(function(Monarch) {
  Monarch.Relations.Table = new JS.Class('Monarch.Relations.Table', {
    initialize: function(recordClass) {
      this.recordClass = recordClass;
      this.name = _.underscoreAndPluralize(recordClass.displayName);
    }
  });
})(Monarch);
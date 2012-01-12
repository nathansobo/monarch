(function(Monarch, $) {
  Monarch.Remote.Server = new JS.Singleton('Monarch.Remote.Server', {
    create: function(record, wireRepresentation) {
      var request = new Monarch.Remote.CreateRequest(record, wireRepresentation);
      return $.ajaxSettings.async ? request : request.record;
    },

    update: function(record, wireRepresentation) {
      var request = new Monarch.Remote.UpdateRequest(record, wireRepresentation);
      return $.ajaxSettings.async ? request : request.record;
    },

    destroy: function(record) {
      return new Monarch.Remote.DestroyRequest(record);
    },

    fetch: function(relationOrArray) {
      var relations = _.isArray(relationOrArray) ? relationOrArray : _.toArray(arguments);
      return new Monarch.Remote.FetchRequest(relations);
    }
  })
})(Monarch, jQuery);

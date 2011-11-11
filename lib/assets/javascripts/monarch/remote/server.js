(function(Monarch) {
  Monarch.Remote.Server = new JS.Singleton('Monarch.Remote.Server', {
    create: function(record, wireRepresentation) {
      return new Monarch.Remote.CreateRequest(record, wireRepresentation);
    },

    update: function(record, wireRepresentation) {
      return new Monarch.Remote.UpdateRequest(record, wireRepresentation);
    },

    destroy: function(record) {
      return new Monarch.Remote.DestroyRequest(record);
    },

    fetch: function() {
      return new Monarch.Remote.FetchRequest(_.toArray(arguments));
    }
  })
})(Monarch);

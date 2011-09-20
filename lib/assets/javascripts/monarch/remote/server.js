(function(Monarch, $) {
  Monarch.Remote.Server = new JS.Singleton('Monarch.Remote.Server', {
    create: function(record, wireRepresentation) {
      return new Monarch.Remote.CreateCommand(record, wireRepresentation);
    },

    update: function(record, wireRepresentation) {
      return new Monarch.Remote.UpdateCommand(record, wireRepresentation);
    },

    destroy: function(record) {
      return new Monarch.Remote.DestroyCommand(record);
    },

    fetch: function() {
      return new Monarch.Remote.FetchCommand(_.toArray(arguments));
    }
  })
})(Monarch, jQuery);

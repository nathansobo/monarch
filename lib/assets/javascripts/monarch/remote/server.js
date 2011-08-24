(function(Monarch) {
  Monarch.Remote.Server = new JS.Singleton('Monarch.Remote.Server', {
    create: function(record, wireRepresentation) {
      return new Monarch.Remote.CreateCommand(record, wireRepresentation);
    },

    update: function(record, wireRepresentation) {
      return new Monarch.Remote.UpdateCommand(record, wireRepresentation);
    },

    destroy: function(record) {
      return new Monarch.Remote.DestroyCommand(record);
    }
  })
})(Monarch);

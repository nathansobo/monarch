(function(Monarch) {
  Monarch.Remote.Server = new JS.Singleton('Monarch.Remote.Server', {
    create: function(record) {
      return new Monarch.Remote.CreateCommand(record);
    }
  })
})(Monarch);

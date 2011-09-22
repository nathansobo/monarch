(function(Monarch) {
  Monarch.Remote.FakeServer = new JS.Singleton('Monarch.Remote.FakeServer', {
    initialize: function() {
      this.reset();
    },

    create: function(record, wireRepresentation) {
      return new Monarch.Remote.FakeCreateCommand(this, record, wireRepresentation);
    },

    update: function(record, wireRepresentation) {
      return new Monarch.Remote.FakeUpdateCommand(record, wireRepresentation);
    },

    destroy: function(record) {
      return new Monarch.Remote.FakeDestroyCommand(record);
    },

    fetch: function() {
      return new Monarch.Remote.FakeFetchCommand(_.toArray(arguments));
    },

    lastCreate: function() {
      return _.last(this.creates);
    },

    reset: function() {
      this.creates = [];
      this.updates = [];
      this.destroys = [];
      this.fetches = [];
    }
  });

  Monarch.Remote.OriginalServer = Monarch.Remote.OriginalServer;

  Monarch.useFakeServer = function() {
    Monarch.Remote.Server = Monarch.Remote.FakeServer;
    Monarch.Remote.Server.reset();
  };

  Monarch.restoreOriginalServer = function() {
    Monarch.Remote.Server = Monarch.Remote.OriginalServer;
  };
})(Monarch);

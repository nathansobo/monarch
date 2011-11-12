(function(Monarch) {
  Monarch.Remote.FakeServer = new JS.Singleton('Monarch.Remote.FakeServer', {
    initialize: function() {
      this.reset();
    },

    create: function(record, wireRepresentation) {
      return new Monarch.Remote.FakeCreateRequest(this, record, wireRepresentation);
    },

    update: function(record, wireRepresentation) {
      return new Monarch.Remote.FakeUpdateRequest(this, record, wireRepresentation);
    },

    destroy: function(record) {
      return new Monarch.Remote.FakeDestroyRequest(this, record);
    },

    fetch: function() {
      return new Monarch.Remote.FakeFetchRequest(this, _.toArray(arguments));
    },

    lastCreate: function() {
      return _.last(this.creates);
    },

    lastUpdate: function() {
      return _.last(this.updates);
    },

    lastDestroy: function() {
      return _.last(this.destroys);
    },

    lastFetch: function() {
      return _.last(this.fetches);
    },

    reset: function() {
      this.creates = [];
      this.updates = [];
      this.destroys = [];
      this.fetches = [];
    }
  });

  Monarch.Remote.OriginalServer = Monarch.Remote.Server;

  Monarch.useFakeServer = function() {
    Monarch.Remote.Server = Monarch.Remote.FakeServer;
    Monarch.Remote.Server.reset();
  };

  Monarch.restoreOriginalServer = function() {
    Monarch.Remote.Server = Monarch.Remote.OriginalServer;
  };
})(Monarch);

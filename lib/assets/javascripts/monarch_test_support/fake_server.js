(function(Monarch) {
  Monarch.Remote.FakeServer = new JS.Singleton('Monarch.Remote.FakeServer', {
    initialize: function() {
      this.reset();
    },

    create: function(record, wireRepresentation) {
      var request = new Monarch.Remote.FakeCreateRequest(this, record, wireRepresentation);
      if (this.auto) request.succeed();
      return request;
    },

    update: function(record, wireRepresentation) {
      var request = new Monarch.Remote.FakeUpdateRequest(this, record, wireRepresentation);
      if (this.auto) request.succeed();
      return request;
    },

    destroy: function(record) {
      var request = new Monarch.Remote.FakeDestroyRequest(this, record);
      if (this.auto) request.succeed();
      return request;
    },

    fetch: function() {
      var request = new Monarch.Remote.FakeFetchRequest(this, _.toArray(arguments));
      if (this.auto) request.succeed();
      return request;
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

  Monarch.useFakeServer = function(auto) {
    Monarch.Remote.Server = Monarch.Remote.FakeServer;
    Monarch.Remote.Server.reset();
    Monarch.Remote.Server.auto = auto;
  };

  Monarch.restoreOriginalServer = function() {
    Monarch.Remote.Server = Monarch.Remote.OriginalServer;
  };
})(Monarch);

(function(Monarch) {
  Monarch.Remote.FakeFetchRequest = new JS.Class("Monarch.Remote.FakeFetchRequest", Monarch.Remote.FetchRequest, {
    initialize: function(fakeServer, relations) {
      this.fakeServer = fakeServer;
      this.callSuper(relations);
      this.fakeServer.fetches.push(this);
    },

    perform: function() { },

    succeed: function(records) {
      Monarch.Repository.update(records);
      this.fakeServer.fetches = _.without(this.fakeServer.fetches, this);
      this.triggerSuccess();
    }
  });
})(Monarch);

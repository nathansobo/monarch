(function(Monarch) {
  Monarch.Remote.FakeDestroyRequest = new JS.Class('Monarch.Remote.FakeDestroyRequest', Monarch.Remote.DestroyRequest, {
    perform: function() {},

    initialize: function(fakeServer, record) {
      this.fakeServer = fakeServer;
      this.callSuper(record);
      fakeServer.destroys.push(this);
    },

    succeed: function() {
      this.fakeServer.destroys = _.without(this.fakeServer.destroys, this);
      this.triggerSuccess();
    }
  })
})(Monarch);

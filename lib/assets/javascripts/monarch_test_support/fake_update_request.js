(function(Monarch) {
  Monarch.Remote.FakeUpdateRequest = new JS.Class('Monarch.Remote.FakeUpdateRequest', Monarch.Remote.UpdateRequest, {
    perform: function() {},

    initialize: function(fakeServer, record, fieldValues) {
      this.fakeServer = fakeServer;
      this.callSuper(record, fieldValues);
      fakeServer.updates.push(this);
    },

    succeed: function(fieldValues) {
      if (!fieldValues) fieldValues = _.clone(this.fieldValues);
      this.fakeServer.updates = _.without(this.fakeServer.updates, this);
      this.triggerSuccess(fieldValues);
    }
  });
})(Monarch);

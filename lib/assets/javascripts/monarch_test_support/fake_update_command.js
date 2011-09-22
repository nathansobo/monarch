(function(Monarch) {
  Monarch.Remote.FakeUpdateCommand = new JS.Class('Monarch.Remote.FakeUpdateCommand', Monarch.Remote.UpdateCommand, {
    perform: function() {},

    initialize: function(fakeServer, record, fieldValues) {
      this.fakeServer = fakeServer;
      this.callSuper(record, fieldValues);
      fakeServer.updates.push(this);
    },

    succeed: function(fieldValues) {
      if (!fieldValues) fieldValues = _.clone(this.fieldValues);
      this.triggerSuccess(fieldValues);
      this.fakeServer.updates = _.without(this.fakeServer.updates, this);
    }
  });
})(Monarch);

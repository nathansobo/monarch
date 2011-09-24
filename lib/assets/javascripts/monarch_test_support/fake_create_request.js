(function(Monarch) {
  Monarch.Remote.FakeCreateRequest = new JS.Class('Monarch.Remote.FakeCreateRequest', Monarch.Remote.CreateRequest, {
    perform: function() {},

    initialize: function(fakeServer, record, fieldValues) {
      this.fakeServer = fakeServer;
      this.callSuper(record, fieldValues);
      fakeServer.creates.push(this);
    },

    succeed: function(fieldValues) {
      if (!fieldValues) fieldValues = _.clone(this.fieldValues);
      var recordWithHighestId = this.record.table.orderBy('id desc').first();
      if (!fieldValues.id) fieldValues.id = (recordWithHighestId ? recordWithHighestId.id() : 0) + 1;
      this.fakeServer.creates = _.without(this.fakeServer.creates, this);
      this.triggerSuccess(fieldValues);
    }
  });
})(Monarch);

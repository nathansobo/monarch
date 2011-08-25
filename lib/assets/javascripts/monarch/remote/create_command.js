(function(Monarch) {
  Monarch.Remote.CreateCommand = new JS.Class('Monarch.Remote.CreateCommand', Monarch.Remote.Command, {
    requestType: 'post',

    requestUrl: function() {
      return Monarch.sandboxUrl + '/' + this.record.table.remoteName;
    },

    requestData: function() {
      return { field_values: this.fieldValues };
    },

    triggerSuccess: function(attributes) {
      this.record.remotelyCreated(attributes);
      this.callSuper(this.record);
    }
  });
})(Monarch, jQuery);

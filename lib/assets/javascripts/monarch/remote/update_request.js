(function(Monarch) {
  Monarch.Remote.UpdateRequest = new JS.Class('Monarch.Remote.UpdateRequest', Monarch.Remote.MutateRequest, {
    requestType: 'put',

    requestUrl: function() {
      return Monarch.sandboxUrl + '/' + this.record.table.remoteName + '/' + this.record.id();
    },

    requestData: function() {
      return { field_values: this.fieldValues };
    },

    triggerSuccess: function(attributes) {
      var changeset = this.record.updated(_.camelizeKeys(attributes));
      this.callSuper(this.record, changeset);
    }
  });
})(Monarch, jQuery);

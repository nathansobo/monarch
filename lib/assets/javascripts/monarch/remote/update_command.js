(function(Monarch) {
  Monarch.Remote.UpdateCommand = new JS.Class('Monarch.Remote.UpdateCommand', Monarch.Remote.Command, {
    requestType: 'put',

    requestUrl: function() {
      return Monarch.sandboxUrl + '/' + this.record.table.remoteName + '/' + this.record.id();
    },

    requestData: function() {
      return { field_values: this.fieldValues };
    },

    triggerSuccess: function(attributes) {
      this.record.updated(attributes);
      this.callSuper(this.record);
    },

    triggerSuccess: function(attributes) {
      var changeset = this.record.updated(_.camelizeKeys(attributes));
      this.callSuper(this.record, changeset);
    }
  });
})(Monarch, jQuery);

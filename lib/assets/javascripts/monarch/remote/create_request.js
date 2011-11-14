//= require ./mutate_request

(function(Monarch) {
  Monarch.Remote.CreateRequest = new JS.Class('Monarch.Remote.CreateRequest', Monarch.Remote.MutateRequest, {
    requestType: 'post',

    requestUrl: function() {
      return Monarch.sandboxUrl + '/' + this.record.table.remoteName;
    },

    requestData: function() {
      return _.isEmpty(this.fieldValues) ? undefined : { field_values: this.fieldValues };
    },

    triggerSuccess: function(attributes) {
      this.record.created(_.camelizeKeys(attributes));
      this.callSuper(this.record);
    }
  });
})(Monarch, jQuery);

//= require ./request

(function(Monarch) {
  Monarch.Remote.CreateRequest = new JS.Class('Monarch.Remote.CreateRequest', Monarch.Remote.Request, {
    requestType: 'post',

    requestUrl: function() {
      return Monarch.sandboxUrl + '/' + this.record.table.remoteName;
    },

    requestData: function() {
      return { field_values: this.fieldValues };
    },

    triggerSuccess: function(attributes) {
      this.record.created(_.camelizeKeys(attributes));
      this.callSuper(this.record);
    }
  });
})(Monarch, jQuery);

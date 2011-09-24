(function(Monarch) {
  Monarch.Remote.DestroyRequest = new JS.Class('Monarch.Remote.DestroyRequest', Monarch.Remote.MutateRequest, {
    requestType: 'delete',

    requestUrl: function() {
      return Monarch.sandboxUrl + '/' + this.record.table.remoteName + '/' + this.record.id();
    },

    requestData: function() {},

    triggerSuccess: function() {
      this.record.destroyed();
      this.callSuper(this.record);
    }
  });
})(Monarch, jQuery);

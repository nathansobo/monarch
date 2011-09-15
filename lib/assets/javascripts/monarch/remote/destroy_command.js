(function(Monarch) {
  Monarch.Remote.DestroyCommand = new JS.Class('Monarch.Remote.DestroyCommand', Monarch.Remote.Command, {
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

(function(Monarch) {
  Monarch.Remote.DestroyCommand = new JS.Class('Monarch.Remote.DestroyCommand', Monarch.Remote.Command, {
    requestType: 'delete',

    requestUrl: function() {
      return Monarch.sandboxUrl + '/' + this.record.table.name + '/' + this.record.id();
    },

    requestData: function() {},

    triggerSuccess: function() {
      this.record.remotelyDestroyed();
      this.callSuper(this.record);
    }
  });
})(Monarch, jQuery);

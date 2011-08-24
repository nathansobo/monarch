(function(Monarch, $) {
  Monarch.Remote.DestroyCommand = new JS.Class('Monarch.Remote.DestroyCommand', {
    include: Monarch.Util.Deferrable,

    initialize: function(record, wireRepresentation) {
      this.callSuper();
      this.record = record;
      $.ajax({
        url: Monarch.sandboxUrl + '/' + record.table.name + '/' + record.id(),
        type: 'delete',
        success: this.method('triggerSuccess')
      });
    },
    
    triggerSuccess: function() {
      var changeset = this.record.remotelyDestroyed();
      this.callSuper(this.record, changeset);
    }
  });
})(Monarch, jQuery);

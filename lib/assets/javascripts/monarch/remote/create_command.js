(function(Monarch, $) {
  Monarch.Remote.CreateCommand = new JS.Class('Monarch.Remote.CreateCommand', {
    include: Monarch.Util.Deferrable,

    initialize: function(record) {
      this.callSuper();
      this.record = record;
      $.ajax({
        url: Monarch.sandboxUrl,
        type: 'post',
        data: JSON.stringify(['create', record.table.name, record.wireRepresentation()]),
        success: this.method('triggerSuccess')
      });
    },

    triggerSuccess: function(attributes) {
      this.record.remotelyCreated(attributes);
      this.callSuper(this.record);
    }
  });
})(Monarch, jQuery);

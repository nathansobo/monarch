(function(Monarch, $) {
  Monarch.Remote.Server = new JS.Singleton('Monarch.Remote.Server', {
    create: function(record, wireRepresentation) {
      return new Monarch.Remote.CreateCommand(record, wireRepresentation);
    },

    update: function(record, wireRepresentation) {
      return new Monarch.Remote.UpdateCommand(record, wireRepresentation);
    },

    destroy: function(record) {
      return new Monarch.Remote.DestroyCommand(record);
    },

    fetch: function() {
      var relationsJson = JSON.stringify(_.map(arguments, function(relation) {
        return relation.wireRepresentation();
      }));

      var promise = new Monarch.Util.Promise();

      $.ajax({
        url: Monarch.sandboxUrl,
        type: 'get',
        data: { relations: relationsJson },
        dataType: 'records',
        success: promise.method('triggerSuccess'),
        error: promise.method('triggerError')
      });

      return promise;
    }
  })
})(Monarch, jQuery);

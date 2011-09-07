(function(Monarch) {
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

      $.ajax({
        url: Monarch.sandboxUrl,
        type: 'get',
        data: { relations: relationsJson }
      });
    }
  })
})(Monarch);

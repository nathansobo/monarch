(function(Monarch, $) {
  Monarch.Remote.FetchCommand = new JS.Class('Monarch.Remote.FetchCommand', {
    include: Monarch.Util.Deferrable,

    initialize: function(relations) {
      this.callSuper();

      this.relations = relations;
      var relationsJson = JSON.stringify(_.map(relations, function(relation) {
        return relation.wireRepresentation();
      }));

      $.ajax({
        url: Monarch.sandboxUrl,
        type: 'get',
        data: { relations: relationsJson },
        dataType: 'records',
        success: this.method('triggerSuccess'),
        error: this.method('triggerError')
      });
    }
  });
})(Monarch, jQuery);

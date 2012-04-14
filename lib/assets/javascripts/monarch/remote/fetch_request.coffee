class Monarch.Remote.FetchRequest extends Monarch.Util.Deferrable
  constructor: (relations) ->
    super()
    @relations = relations
    @perform()

  perform: ->
    relationsJson = JSON.stringify(relation.wireRepresentation() for relation in @relations)
    jQuery.ajax
      url: Monarch.fetchUrl
      type: 'get'
      data: { relations: relationsJson }
      dataType: 'records'
      success: (args...) => @triggerSuccess(args...)
      error: (args...) => @triggerError(args...)

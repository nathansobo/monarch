_.extend Monarch.Relations.Projection.prototype,
  all: ->
    if @_contents
      @_contents.values()
    else
      _.uniq(@retrieveRecords())

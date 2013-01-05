Monarch.Relations.Projection.reopen ->
  all: ->
    if @_contents
      @_contents.values()
    else
      _.uniq(@retrieveRecords())

Monarch.Util.reopen Monarch.Relations.Projection, ->
  all: ->
    if @_contents
      @_contents.values()
    else
      _.uniq(@retrieveRecords())

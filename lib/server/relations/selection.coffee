module.exports = (Selection) ->

  Selection.reopen ->
    for methodName in ['updateSql', 'deleteSql', 'updateAll', 'deleteAll']
      do (methodName) =>
        this::[methodName] = ->
          @operand[methodName].apply(this, arguments)


{ reopen } = require("../core").Util

module.exports = (Selection) ->

  reopen Selection, ->
    for methodName in ['updateSql', 'deleteSql', 'updateAll', 'deleteAll']
      do (methodName) =>
        this::[methodName] = ->
          @operand[methodName].apply(this, arguments)


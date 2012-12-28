{ reopen } = require("../core").Util

module.exports = (Selection) ->

  reopen Selection, ->
    updateSql: ->
      @operand.updateSql.apply(this, arguments)

    updateAll: ->
      @operand.updateAll.apply(this, arguments)


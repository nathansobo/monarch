do (jQuery) ->
  jQuery.ajaxSetup
    converters:
      "json records": (json) ->
        Monarch.Repository.update(json)
      "json records!": (json) ->
        Monarch.Repository.clear()
        Monarch.Repository.update(json)
      "json data+records": (json) ->
        Monarch.Repository.update(json.records)
        json.data
      "json data+records!": (json) ->
        Monarch.Repository.clear()
        Monarch.Repository.update(json.records)
        json.data

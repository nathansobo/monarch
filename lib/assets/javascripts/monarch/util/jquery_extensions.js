(function(Monarch, jQuery) {

jQuery.ajaxSetup({
  converters: {
    "json records": function(json) {
      Monarch.Repository.update(json);
    },
    "json records!": function(json) {
      Monarch.Repository.clear();
      Monarch.Repository.update(json);
    },
    "json data+records": function(json) {
      Monarch.Repository.update(json.records);
      return json.data;
    },
    "json data+records!": function(json) {
      Monarch.Repository.clear();
      Monarch.Repository.update(json.records);
      return json.data;
    }
  }
});

})(Monarch, jQuery);

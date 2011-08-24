//= require jquery
//= require monarch

var lastAjaxRequest;



beforeEach(function() {
  lastAjaxRequest = undefined;

  spyOn($, 'ajax').andCallFake(function(request) {
    lastAjaxRequest = request;
  });
});
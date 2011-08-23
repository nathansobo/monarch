//= require jquery
//= require monarch

var lastAjaxRequest;

beforeEach(function() {
  spyOn($, 'ajax').andCallFake(function(request) {
    lastAjaxRequest = request;
  });
});
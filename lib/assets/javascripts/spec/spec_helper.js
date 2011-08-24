//= require jquery
//= require monarch

var lastAjaxRequest;



beforeEach(function() {
  lastAjaxRequest = undefined;

  spyOn($, 'ajax').andCallFake(function(request) {
    lastAjaxRequest = request;
  });
});

afterEach(function() {
  _.each(Monarch.Record.subclasses, function(recordSubclass) {
    delete window[recordSubclass.displayName];
  });
  Monarch.Record.subclasses = [];
});
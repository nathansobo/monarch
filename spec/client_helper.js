//= require ./vendor/underscore
//= require ./vendor/jquery
//= require ./support/fake_xhr
//= require ../lib/client/index
//= require ../lib/client_test_support/index

var lastAjaxRequest;

beforeEach(function() {
  lastAjaxRequest = undefined;
  mockXhr();
  this.env.addEqualityTester(_.isEqual);
  Monarch.Repository.tables = {};
});

afterEach(function() {
  _.each(Monarch.Record.subclasses, function(recordSubclass) {
    delete window[recordSubclass.displayName];
  });
  Monarch.Record.subclasses = [];
  Monarch.Repository.clear();
  Monarch.snakeCase = false;
});

function unspy(object, methodName) {
  if (!jasmine.isSpy(object[methodName])) return;
  object[methodName] = object[methodName].originalValue;
}

function mockXhr() {
  spyOn($, 'ajax').andCallFake(function(request) {
    lastAjaxRequest = request;
  });
}

function mockLowLevelXhr() {
  unspy(jQuery, 'ajax');
  spyOn(jQuery.ajaxSettings, 'xhr').andCallFake(function() {
    return lastAjaxRequest = new FakeXHR();
  });
}

jasmine.Spy.prototype.arg = function(n) {
  return this.mostRecentCall.args[n];
};

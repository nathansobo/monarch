//= require_tree ./support

var ajaxRequests;
var lastAjaxRequest;

beforeEach(function() {
  ajaxRequests = []
  lastAjaxRequest = undefined;
  mockXhr();
  this.env.addEqualityTester(_.isEqual);
  Monarch.Repository.tables = {};
});

beforeEach(function() {
  this.addMatchers({
    toHaveSubscriptions: function() {
      var relation = this.actual;
      if (!relation.isActive) return false;
      var subscriptionCount =
        relation._insertNode.size() +
        relation._updateNode.size() +
        relation._removeNode.size();
      return (subscriptionCount > 0);
    }
  });
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
    ajaxRequests.push(request);
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

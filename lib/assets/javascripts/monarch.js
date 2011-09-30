//= require js.class/core
//= require js.class/enumerable
//= require js.class/hash
//= require js.class/set
//= require js.class/forwardable
//= require underscore
//= require_self
//= require_tree ./monarch/util
//= require_tree ./monarch


function Monarch(recordClassName, columnDefinitions) {
  var recordClass = new JS.Class(recordClassName, Monarch.Record);
  if (columnDefinitions) recordClass.columns(columnDefinitions);
  return recordClass;
}

_.extend(Monarch, {
  sandboxUrl: '/sandbox',

  Expressions: {},
  Relations: {},
  Remote: {},
  Util: {},

  fetch: function() {
    var server = Monarch.Remote.Server;
    return server.fetch.apply(server, arguments);
  }
});

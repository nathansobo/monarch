(function(Monarch) {
  Monarch.Util.SkipListNode = new JS.Class('Monarch.Util.SkipListNode', {
    initialize: function(level, key, value) {
      this.key = key;
      this.value = value;
      this.level = level;
      this.pointer = new Array(level);
      this.distance = new Array(level);
    }
  });
})(Monarch);

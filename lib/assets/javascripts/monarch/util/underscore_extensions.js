_.mixin({
  sum: function(array) {
    var len = array.length
    var sum = 0;
    for (var i = 0; i < len; i++) {
      sum += array[i];
    }
    return sum;
  }
});
function FakeXHR() {
  var xhr = {
    requestHeaders: {},

    open: function() {
      xhr.method = arguments[0];
      xhr.url = arguments[1];
      xhr.readyState = 1;
    },

    setRequestHeader: function(header, value) {
      xhr.requestHeaders[header] = value;
    },

    abort: function() {
      xhr.readyState = 0;
    },

    readyState: 0,

    onreadystatechange: function(isTimeout) {
    },

    status: null,

    send: function(data) {
      xhr.params = data;
      xhr.readyState = 2;
    },

    getResponseHeader: function(name) {
      return xhr.responseHeaders[name];
    },

    getAllResponseHeaders: function() {
      var responseHeaders = [];
      for (var i in xhr.responseHeaders) {
        if (xhr.responseHeaders.hasOwnProperty(i)) {
          responseHeaders.push(i + ': ' + xhr.responseHeaders[i]);
        }
      }
      return responseHeaders.join('\r\n');
    },

    responseText: null,

    response: function(response) {
      xhr.status = response.status;
      xhr.responseText = response.responseText || "";
      xhr.readyState = 4;
      xhr.responseHeaders = response.responseHeaders || {"Content-type": response.contentType || "application/json" };
      xhr.onreadystatechange();
    },

    responseTimeout: function() {
      xhr.readyState = 4;
      jasmine.Clock.tick(jQuery.ajaxSettings.timeout || 30000);
      xhr.onreadystatechange('timeout');
    }
  };

  return xhr;
}

(function(Monarch, $) {
  Monarch.Remote.Request = new JS.Class('Monarch.Remote.Request', {
    include: Monarch.Util.Deferrable,

    initialize: function(record, fieldValues) {
      this.callSuper();
      this.record = record;
      this.fieldValues = fieldValues;

      Monarch.Repository.pauseUpdates();
      this.perform();
    },

    perform: function() {
      $.ajax({
        url: this.requestUrl(),
        type: this.requestType,
        data: this.requestData(),
        dataType: 'json',
        success: this.method('triggerSuccess'),
        error: this.method('handleError')
      });
    },

    triggerSuccess: function() {
      this.callSuper.apply(this, arguments);
      Monarch.Repository.resumeUpdates();
    },

    triggerInvalid: function(errors) {
      this.record.errors.assign(errors);
      this.callSuper(this.record);
      Monarch.Repository.resumeUpdates();
    },

    handleError: function(error) {
      if (error.status === 422) {
        this.triggerInvalid(JSON.parse(error.responseText));
      }
    }
  });
})(Monarch, jQuery);

(function(Monarch, $) {
  Monarch.Remote.Command = new JS.Class('Monarch.Remote.Command', {
    include: Monarch.Util.Deferrable,

    initialize: function(record, fieldValues) {
      this.callSuper();
      this.record = record;
      this.fieldValues = fieldValues;

      $.ajax({
        url: this.requestUrl(),
        type: this.requestType,
        data: this.requestData(),
        success: this.method('triggerSuccess'),
        error: this.method('handleError')
      });
    },

    triggerInvalid: function(errors) {
      this.record.errors.assign(errors);
      this.callSuper(this.record);
    },

    handleError: function(error) {
      if (error.status === 422) {
        this.triggerInvalid(JSON.parse(error.responseText));
      }
    }
  });
})(Monarch, jQuery);

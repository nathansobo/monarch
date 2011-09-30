describe("Extensions to the JS.Class Kernel module", function() {
  describe("#bind", function() {
    it("binds the given function in the receiving object", function() {
      var Klass = new JS.Class();
      var obj = new Klass();

      obj.bind(function() {
        expect(this).toBe(obj);
      })();
    });
  });
});

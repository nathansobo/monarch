describe("Monarch", function() {
  describe("calling the top level Monarch constant as a function", function() {
    it("returns a record class by the given name", function() {
      var klass = Monarch("Blog");
      expect(klass.isA(JS.Class)).toBeTruthy();
      expect(klass.superclass).toBe(Monarch.Record);
    });
  });
});

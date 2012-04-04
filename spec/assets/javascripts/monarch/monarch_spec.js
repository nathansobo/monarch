describe("Monarch", function() {
  describe("calling the top level Monarch constant as a function", function() {
    it("returns a record class by the given name with the given column definitions", function() {
      var klass = Monarch("Blog", {
        title: 'string',
        userId: 'integer'
      });
      expect(klass.isA(JS.Class)).toBeTruthy();
      expect(klass.superclass).toBe(Monarch.Record);
      expect(klass.getColumn('title').type).toBe('string');
      expect(klass.getColumn('userId').type).toBe('integer');
    });
  });
});

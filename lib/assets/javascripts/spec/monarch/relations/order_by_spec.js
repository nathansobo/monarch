describe("Monarch.Relations.OrderBy", function() {
  beforeEach(function() {
    User = new JS.Class('User', Monarch.Record);
    User.columns({
      firstName: 'firstName',
      lastName: 'lastName'
    });
  });

  describe("#all()", function() {
    it("returns the contents of the operand, sorted by the specified columns", function() {
      var user1 = User.remotelyCreated({id: 1, firstName: "A", lastName: "E"});
      var user2 = User.remotelyCreated({id: 2, firstName: "A", lastName: "C"});
      var user3 = User.remotelyCreated({id: 3, firstName: "A", lastName: "A"});
      var user4 = User.remotelyCreated({id: 4, firstName: "B", lastName: "A"});
      var records = User.orderBy('lastName', 'firstName desc').all();
      expect(records).toEqual([user4, user3, user2, user1]);
    });
  });
});
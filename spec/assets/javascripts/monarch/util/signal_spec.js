describe("Monarch.Util.Signal", function() {
  describe("multiple signals combined", function() {
    it("applies the transformer to all the input sources", function() {
      User = new JS.Class('User', Monarch.Record);

      User.columns({
        firstName: 'string',
        middleName: 'string',
        lastName: 'string'
      });

      User.syntheticColumn('fullName', function() {
        return this.signal('firstName', 'middleName', 'lastName');
      });

      User.syntheticColumn('lastFirst', function() {
        return this.signal('firstName', 'middleName', 'lastName', function(first, middle, last) {
          return last + ", " + first + ", " + middle;
        });
      });

      var user = User.created({id: 1, firstName: "John", lastName: "Smith", middleName: "Roy"});
      var changeCallback = jasmine.createSpy('changeCallback');

      user.signal('fullName').onChange(changeCallback);

      expect(user.fullName()).toEqual("John Roy Smith");

      user.updated({firstName: "Bob"});

      expect(changeCallback).toHaveBeenCalledWith("Bob Roy Smith", "John Roy Smith");

      user.updated({lastName: "Dole"});

      expect(changeCallback).toHaveBeenCalledWith("Bob Roy Dole", "Bob Roy Smith");

      user.updated({middleName: "Doink"});

      expect(changeCallback).toHaveBeenCalledWith("Bob Doink Dole", "Bob Roy Dole");

      expect(user.lastFirst()).toBe("Dole, Bob, Doink");
    });
  });
});

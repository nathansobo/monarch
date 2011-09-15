describe("Monarch.Relations.OrderBy", function() {
  var user1, user2, user3, user4;
  beforeEach(function() {
    User = new JS.Class('User', Monarch.Record);
    User.columns({
      firstName: 'firstName',
      lastName: 'lastName'
    });

    user1 = User.created({id: 1, firstName: "A", lastName: "E"});
    user2 = User.created({id: 2, firstName: "A", lastName: "C"});
    user3 = User.created({id: 3, firstName: "A", lastName: "A"});
    user4 = User.created({id: 4, firstName: "B", lastName: "A"});
  });

  describe("#all()", function() {
    it("returns the contents of the operand, sorted by the specified columns", function() {
      var records = User.orderBy('lastName', 'firstName desc').all();
      expect(records).toEqual([user4, user3, user2, user1]);
    });
  });

  describe("events", function() {
    var orderBy, insertCallback, updateCallback, removeCallback, subscriptions;

    beforeEach(function() {
      orderBy = User.orderBy('lastName', 'firstName desc');
      subscriptions = new Monarch.Util.SubscriptionBundle();
      insertCallback = jasmine.createSpy('insertCallback');
      updateCallback = jasmine.createSpy('updateCallback');
      removeCallback = jasmine.createSpy('removeCallback');
      subscribe(orderBy);
    });

    function subscribe(rel) {
      subscriptions.destroy();
      subscriptions.add(rel.onInsert(insertCallback));
      subscriptions.add(rel.onUpdate(updateCallback));
      subscriptions.add(rel.onRemove(removeCallback));
      return rel;
    }

    describe("insert events", function() {
      it("triggers insert events with the appropriate indices when a record is inserted into the operand", function() {
        var user5 = User.created({id: 5, firstName: "A", lastName: "B"});
        expect(insertCallback).toHaveBeenCalled();
        expect(insertCallback.arg(0)).toBe(user5);
        expect(insertCallback.arg(1)).toBe(2);
      });
    });

    describe("update events", function() {
      it("triggers update events with the appropriate indices when a record is updated in the operand", function() {
        user2.updated({lastName: "A", firstName: "AB"});
        expect(updateCallback).toHaveBeenCalled();
        expect(updateCallback.arg(0)).toBe(user2);
        expect(updateCallback.arg(1)).toEqual({
          firstName: {
            oldValue: "A",
            newValue: "AB",
            column: User.firstName
          },
          lastName: {
            oldValue: "C",
            newValue: "A",
            column: User.lastName
          }
        });
        expect(updateCallback.arg(2)).toBe(1);
        expect(updateCallback.arg(3)).toBe(2);
      });
    });

    describe("remove events", function() {
      it("triggers remove events when a record is removed in the operand", function() {
        user3.destroyed();
        expect(removeCallback).toHaveBeenCalled();
        expect(removeCallback.arg(0)).toBe(user3);
        expect(removeCallback.arg(1)).toBe(1);
      });

      it("correctly removes records when the removal from the operand is caused by an order-changing update", function() {
        subscribe(User.where({lastName: "A"}).orderBy('firstName'));
        user4.updated({lastName: "Z", firstName: "0 A"});

        expect(removeCallback).toHaveBeenCalled();
        expect(removeCallback.arg(0)).toBe(user4);
        expect(removeCallback.arg(1)).toBe(1);
      });
    });
  });
});

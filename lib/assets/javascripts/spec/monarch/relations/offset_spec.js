describe("Monarch.Relations.Offset", function() {
  beforeEach(function() {
    BlogPost = new JS.Class('BlogPost', Monarch.Record);
    BlogPost.columns({
      title: "string"
    });
    BlogPost.defaultOrderBy('title');
  });

  describe("#all()", function() {
    it("returns the records from the operand with the first 'count' discarded", function() {
      var post1 = BlogPost.created({id: 1, title: "Alpha"});
      var post2 = BlogPost.created({id: 2, title: "Bravo"});
      var post3 = BlogPost.created({id: 3, title: "Charlie"});
      var post4 = BlogPost.created({id: 4, title: "Delta"});

      expect(BlogPost.offset(2).all()).toEqual([post3, post4]);
    });
  });

  describe("events", function() {
    var subscriptions, insertCallback, updateCallback, removeCallback;
    var post1, post2, post3;

    beforeEach(function() {
      subscriptions = new Monarch.Util.SubscriptionBundle();
      insertCallback = jasmine.createSpy('insertCallback');
      updateCallback = jasmine.createSpy('updateCallback');
      removeCallback = jasmine.createSpy('removeCallback');

      var relation = BlogPost.offset(2);
      subscriptions.add(relation.onInsert(insertCallback));
      subscriptions.add(relation.onUpdate(updateCallback));
      subscriptions.add(relation.onRemove(removeCallback));

      post1 = BlogPost.created({id: 1, title: "Alpha"});
      post2 = BlogPost.created({id: 2, title: "Charlie"});
      expect(insertCallback).not.toHaveBeenCalled();
      post3 = BlogPost.created({id: 3, title: "Echo"});
      insertCallback.reset();
    });

    describe("insert events", function() {
      it("triggers an insert event when a record is inserted in the operand with an index >= count", function() {
        var post4 = BlogPost.created({id: 4, title: "Golf"});
        expect(insertCallback).toHaveBeenCalled();
        expect(insertCallback.arg(0)).toBe(post4);
        expect(insertCallback.arg(1)).toBe(1);
      });

      it("triggers an insert event for the new first record when a record is inserted with an index < count and there are enough records to exceed the offset", function() {
        BlogPost.created({id: 4, title: "Bravo"});
        expect(insertCallback).toHaveBeenCalled();
        expect(insertCallback.arg(0)).toBe(post2);
        expect(insertCallback.arg(1)).toBe(0);
      });

      it("triggers an insert event when an operand record is updated from an index less than count to an index >= count", function() {
        post1.updated({title: "Uniform"});
        expect(insertCallback).toHaveBeenCalled();
        expect(insertCallback.arg(0)).toBe(post1);
        expect(insertCallback.arg(1)).toBe(0);
      });

      it("triggers an insert event for the new first record when a record is updated to be less than count and pushes it into place", function() {
        post3.updated({title: "Bravo"});
        expect(insertCallback).toHaveBeenCalled();
        expect(insertCallback.arg(0)).toBe(post2);
        expect(insertCallback.arg(1)).toBe(0);
      });
    });

    describe("update events", function() {
      it("triggers an update event when a tuple is updated from an index >= count to and index >= count", function() {
        post3.updated({title: "Zulu"});
        expect(updateCallback).toHaveBeenCalled();
        expect(updateCallback.arg(0)).toBe(post3);
        expect(updateCallback.arg(1)).toEqual({
          title: {
            oldValue: "Echo",
            newValue: "Zulu",
            column: BlogPost.title
          }
        });
        expect(updateCallback.arg(2)).toBe(0);
        expect(updateCallback.arg(3)).toBe(0);
        updateCallback.reset();

        post1.updated({title: "Bravo"});
        expect(updateCallback).not.toHaveBeenCalled();
      });
    });

    describe("remove events", function() {
      it("triggers a remove event when a tuple is removed with an index >= count", function() {
        post3.destroyed();
        expect(removeCallback).toHaveBeenCalled();
        expect(removeCallback.arg(0)).toBe(post3);
        expect(removeCallback.arg(1)).toBe(0);
      });

      it("triggers a remove event when a tuple is updated in the operand from an index >= count to an index < count", function() {
        post3.updated({title: "Bravo"});
        expect(removeCallback).toHaveBeenCalled();
        expect(removeCallback.arg(0)).toBe(post3);
        expect(removeCallback.arg(1)).toBe(0);
      });

      it("triggers a remove event for the first tuple when a tuple is removed from the operand with an index < count", function() {
        post1.destroyed();
        expect(removeCallback).toHaveBeenCalled();
        expect(removeCallback.arg(0)).toBe(post3);
        expect(removeCallback.arg(1)).toBe(0);
      });

      it("triggers a remove event for the first tuple when a tuple is updated in the operand from an index < count to an index >= count", function() {
        post1.updated({title: "Zulu"});
        expect(removeCallback).toHaveBeenCalled();
        expect(removeCallback.arg(0)).toBe(post3);
        expect(removeCallback.arg(1)).toBe(0);
      });
    });
  });

  it("has a #wireRepresentation()", function() {
    expect(BlogPost.offset(5).wireRepresentation()).toEqual({
      type: 'offset',
      operand: BlogPost.table.wireRepresentation(),
      count: 5
    });
  });
});

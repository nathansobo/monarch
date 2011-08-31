describe("Monarch.Relations.Limit", function() {
  beforeEach(function() {
    BlogPost = new JS.Class('BlogPost', Monarch.Record);
    BlogPost.columns({
      title: "string"
    });
    BlogPost.defaultOrderBy('title');
  });

  describe("#all()", function() {
    it("returns up to 'count' records", function() {
      var post1 = BlogPost.remotelyCreated({id: 1, title: "Alpha"});
      var post2 = BlogPost.remotelyCreated({id: 2, title: "Bravo"});
      var post3 = BlogPost.remotelyCreated({id: 3, title: "Charlie"});

      expect(BlogPost.limit(2).all()).toEqual([post1, post2]);
      expect(BlogPost.limit(4).all()).toEqual([post1, post2, post3]);
    });
  });

  describe("events", function() {
    var insertCallback, updateCallback, removeCallback;

    beforeEach(function() {
      insertCallback = jasmine.createSpy('insertCallback');
      updateCallback = jasmine.createSpy('updateCallback');
      removeCallback = jasmine.createSpy('removeCallback');
    });

    var subscriptions;

    function subscribe(relation) {
      if (subscriptions) {
        subscriptions.destroy();
      } else {
        subscriptions = new Monarch.Util.SubscriptionBundle();
      }

      subscriptions.add(relation.onInsert(insertCallback));
      subscriptions.add(relation.onUpdate(updateCallback));
      subscriptions.add(relation.onRemove(removeCallback));
      return relation;
    }

    describe("insert events", function() {
      it("triggers insert events if tuples are added to the operand at an index lower than the count", function() {
        subscribe(BlogPost.limit(2));

        var post1 = BlogPost.remotelyCreated({id: 1, title: "Alpha"});
        expect(insertCallback).toHaveBeenCalled();
        expect(insertCallback.arg(0)).toBe(post1);
        expect(insertCallback.arg(1)).toBe(0);
        insertCallback.reset();

        var post2 = BlogPost.remotelyCreated({id: 2, title: "Bravo"});
        expect(insertCallback).toHaveBeenCalled();
        expect(insertCallback.arg(0)).toBe(post2);
        expect(insertCallback.arg(1)).toBe(1);
        insertCallback.reset();

        BlogPost.remotelyCreated({id: 3, title: "Charlie"});
        expect(insertCallback).not.toHaveBeenCalled();
      });

      it("triggers insert events if tuples are updated in the operand to have and index falling under the count", function() {
        var post1 = BlogPost.remotelyCreated({id: 1, title: "Alpha"});
        var post2 = BlogPost.remotelyCreated({id: 2, title: "Charlie"});
        var post3 = BlogPost.remotelyCreated({id: 3, title: "Echo"});
        subscribe(BlogPost.limit(2));

        post3.remotelyUpdated({title: "Bravo"});
        expect(insertCallback).toHaveBeenCalled();
        expect(insertCallback.arg(0)).toBe(post3);
        expect(insertCallback.arg(1)).toBe(1);
        insertCallback.reset();
        
        post3.remotelyUpdated({title: "0 Alpha"});
        expect(insertCallback).not.toHaveBeenCalled();
      });

      it("triggers insert events if a removed tuple causes a new tuple to fall under the count", function() {
        var post1 = BlogPost.remotelyCreated({id: 1, title: "Alpha"});
        var post2 = BlogPost.remotelyCreated({id: 2, title: "Charlie"});
        var post3 = BlogPost.remotelyCreated({id: 3, title: "Echo"});
        subscribe(BlogPost.limit(2));

        post2.remotelyUpdated({title: "Zulu"});
        expect(insertCallback).toHaveBeenCalled();
        expect(insertCallback.arg(0)).toBe(post3);
        expect(insertCallback.arg(1)).toBe(1);
        insertCallback.reset();

        post1.remotelyDestroyed();
        expect(insertCallback).toHaveBeenCalled();
        expect(insertCallback.arg(0)).toBe(post2);
        expect(insertCallback.arg(1)).toBe(1);
        insertCallback.reset();

        post2.remotelyDestroyed();
        expect(insertCallback).not.toHaveBeenCalled();
      });
    });

    describe("update events", function() {
      it("triggers update events if a tuple in the operand with an index below the count is updated to keep its index below the count", function() {
        var post1 = BlogPost.remotelyCreated({id: 1, title: "Alpha"});
        var post2 = BlogPost.remotelyCreated({id: 2, title: "Charlie"});
        var post3 = BlogPost.remotelyCreated({id: 3, title: "Echo"});
        subscribe(BlogPost.limit(2));

        post1.remotelyUpdated({title: "Delta"});
        expect(updateCallback).toHaveBeenCalled();
        expect(updateCallback.arg(0)).toBe(post1);
        expect(updateCallback.arg(1)).toEqual({
          title: {
            oldValue: "Alpha",
            newValue: "Delta",
            column: BlogPost.title
          }
        });
        expect(updateCallback.arg(2)).toBe(1);
        expect(updateCallback.arg(3)).toBe(0);
        updateCallback.reset();

        post3.remotelyUpdated({title: "Foxtrot"});
        expect(updateCallback).not.toHaveBeenCalled();

        post2.remotelyUpdated({title: "Uniform"});
        expect(updateCallback).not.toHaveBeenCalled();

        post2.remotelyUpdated({title: "Alpha"});
        expect(updateCallback).not.toHaveBeenCalled();
      });
    });

    describe("remove events", function() {
      var post1, post2, post3;
      beforeEach(function() {
        post1 = BlogPost.remotelyCreated({id: 1, title: "Alpha"});
        post2 = BlogPost.remotelyCreated({id: 2, title: "Charlie"});
        post3 = BlogPost.remotelyCreated({id: 3, title: "Echo"});
        subscribe(BlogPost.limit(2));
      });

      it("triggers remove events when a tuple in the operand is removed with an index lower than count", function() {
        post2.remotelyDestroyed();
        expect(removeCallback).toHaveBeenCalled();
        expect(removeCallback.arg(0)).toBe(post2);
        expect(removeCallback.arg(1)).toBe(1);
      });

      it("triggers remove events when a tuple with an index lower than the count is updated to have an index higher than the count", function() {
        post1.remotelyUpdated({title: "Uniform"});
        expect(removeCallback).toHaveBeenCalled();
        expect(removeCallback.arg(0)).toBe(post1);
        expect(removeCallback.arg(1)).toBe(0);
      });

      it("triggers remove events when the insertion of a tuple causes the last tuple to fall off the end of the limit", function() {
        // updates
        post3.remotelyUpdated({title: "Bravo"});
        expect(removeCallback).toHaveBeenCalled();
        expect(removeCallback.arg(0)).toBe(post2);
        expect(removeCallback.arg(1)).toBe(1);
        removeCallback.reset();

        // inserts
        BlogPost.remotelyCreated({id: 4, title: "0 Alpha"});
        expect(removeCallback).toHaveBeenCalled();
        expect(removeCallback.arg(0)).toBe(post3);
        expect(removeCallback.arg(1)).toBe(1);
      });
    });
  });
});
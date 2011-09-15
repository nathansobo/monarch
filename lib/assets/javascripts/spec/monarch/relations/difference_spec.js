describe("Monarch.Relations.Difference", function() {
  beforeEach(function() {
    BlogPost = new JS.Class('BlogPost', Monarch.Record);
    BlogPost.columns({
      public: 'boolean',
      blogId: 'integer',
      title: 'string'
    });
    BlogPost.defaultOrderBy('title');
  });

  describe("#all()", function() {
    it("returns relations in the left operand that aren't in the right", function() {
      var post1 = BlogPost.created({id: 1, title: "Alpha", blogId: 1, public: false});
      var post2 = BlogPost.created({id: 2, title: "Bravo", blogId: 1, public: false});
      var post3 = BlogPost.created({id: 3, title: "Charlie", blogId: 1, public: true});
      var post4 = BlogPost.created({id: 4, title: "Delta", blogId: 2, public: true});

      var records = BlogPost.where({blogId: 1}).difference(BlogPost.where({public: true})).all();
      expect(records).toEqual([post1, post2]);
    });
  });

  describe("events", function() {
    var difference, insertCallback, updateCallback, removeCallback, subscriptions;

    beforeEach(function() {
      difference = BlogPost.where({blogId: 1}).difference(BlogPost.where({public: true}));
      subscriptions = new Monarch.Util.SubscriptionBundle();
      insertCallback = jasmine.createSpy('insertCallback');
      updateCallback = jasmine.createSpy('updateCallback');
      removeCallback = jasmine.createSpy('removeCallback');

      subscriptions.add(difference.onInsert(insertCallback));
      subscriptions.add(difference.onUpdate(updateCallback));
      subscriptions.add(difference.onRemove(removeCallback));
    });

    describe("insert events", function() {
      it("triggers insert events when a tuple is inserted into the left operand that isn't present in the right", function() {
        var post1 = BlogPost.created({id: 1, blogId: 1, title: "Alpha", public: false});
        expect(insertCallback).toHaveBeenCalled();
        expect(insertCallback.arg(0)).toBe(post1);
        expect(insertCallback.arg(1)).toBe(0);
        insertCallback.reset();

        var post2 = BlogPost.created({id: 2, blogId: 1, title: "Bravo", public: false});
        expect(insertCallback).toHaveBeenCalled();
        expect(insertCallback.arg(0)).toBe(post2);
        expect(insertCallback.arg(1)).toBe(1);
        insertCallback.reset();

        BlogPost.created({id: 3, blogId: 1, title: "Charlie", public: true});
        expect(insertCallback).not.toHaveBeenCalled();
      });

      it("triggers insert events when a tuple that's present in both operands is removed from the right", function() {
        var post1 = BlogPost.created({id: 1, blogId: 1, title: "Alpha", public: true});
        var post2 = BlogPost.created({id: 2, blogId: 100, title: "Bravo", public: true});
        expect(insertCallback).not.toHaveBeenCalled();

        post1.updated({public: false});
        expect(insertCallback).toHaveBeenCalled();
        expect(insertCallback.arg(0)).toBe(post1);
        expect(insertCallback.arg(1)).toBe(0);
        insertCallback.reset();

        post2.updated({public: false});
        expect(insertCallback).not.toHaveBeenCalled();
      });
    });

    describe("update events", function() {
      it("triggers update events when a record in the left operand that is not in the right is updated", function() {
        var post1 = BlogPost.created({id: 1, blogId: 1, title: "Alpha", public: false});
        var post2 = BlogPost.created({id: 2, blogId: 1, title: "Bravo", public: false});
        var post3 = BlogPost.created({id: 3, blogId: 1, title: "Charlie", public: true});

        post1.updated({title: "Zulu"});
        expect(updateCallback).toHaveBeenCalled();
        expect(updateCallback.arg(0)).toBe(post1);
        expect(updateCallback.arg(1)).toEqual({
          title: {
            oldValue: "Alpha",
            newValue: "Zulu",
            column: BlogPost.title
          }
        });
        expect(updateCallback.arg(2)).toBe(1);
        expect(updateCallback.arg(3)).toBe(0);
        updateCallback.reset();
        
        post3.updated({title: "Uniform"});
        expect(updateCallback).not.toHaveBeenCalled();
      });
    });

    describe("remove events", function() {
      var post1, post2, post3, post4;
      beforeEach(function() {
        post1 = BlogPost.created({id: 1, blogId: 1, title: "Alpha", public: false});
        post2 = BlogPost.created({id: 2, blogId: 1, title: "Bravo", public: false});
        post3 = BlogPost.created({id: 3, blogId: 1, title: "Charlie", public: false});
        post4 = BlogPost.created({id: 4, blogId: 1, title: "Delta", public: true});
      });

      it("triggers remove events if a tuple is removed from the left operand", function() {
        post3.destroyed();
        expect(removeCallback).toHaveBeenCalled();
        expect(removeCallback.arg(0)).toBe(post3);
        expect(removeCallback.arg(1)).toBe(2);
        removeCallback.reset();

        post4.updated({blogId: 100});
        expect(removeCallback).not.toHaveBeenCalled();
      });

      it("triggers remove events if a tuple in the left operand is inserted into the right", function() {
        post2.updated({public: true});
        expect(removeCallback).toHaveBeenCalled();
        expect(removeCallback.arg(0)).toBe(post2);
        expect(removeCallback.arg(1)).toBe(1);
      });
    });
  });

  it("has a #wireRepresentation", function() {
    var left = BlogPost.where({blogId: 1});
    var right = BlogPost.where({public: true});

    expect(left.difference(right).wireRepresentation()).toEqual({
      type: 'difference',
      left_operand: left.wireRepresentation(),
      right_operand: right.wireRepresentation()
    });
  });
});
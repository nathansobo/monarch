describe("Monarch.Relations.InnerJoin", function() {
  beforeEach(function() {
    Blog = new JS.Class('Blog', Monarch.Record);
    Blog.columns({
      userId: 'integer',
      title: 'string'
    });
    Blog.defaultOrderBy('title');


    BlogPost = new JS.Class('BlogPost', Monarch.Record);
    BlogPost.columns({
      blogId: 'integer',
      title: 'string'
    });
    BlogPost.defaultOrderBy('title');
  });

  describe("#initialize(left, right, predicate=null)", function() {
    it("infers the predicate if one is not provided", function() {
      var inferred = Blog.where({userId: 1}).join(BlogPost);
      var explicit = Blog.where({userId: 1}).join(BlogPost, {blogId: Blog.id});
      expect(inferred).toEqual(explicit);
    });
  });

  describe("#all()", function() {
    it("returns composite tuples from the cartesian product that match the predicate", function() {
      var blog1 = Blog.remotelyCreated({id: 1, userId: 1, title: "Alpha"});
      var blog2 = Blog.remotelyCreated({id: 2, userId: 2, title: "Bravo"});
      var blog3 = Blog.remotelyCreated({id: 3, userId: 1, title: "Charlie"});
      var post1 = BlogPost.remotelyCreated({id: 1, blogId: 1, title: "Alpha Post 1"});
      var post2 = BlogPost.remotelyCreated({id: 2, blogId: 1, title: "Alpha Post 2"});
      var post3 = BlogPost.remotelyCreated({id: 3, blogId: 2, title: "Bravo Post 1"});
      var post4 = BlogPost.remotelyCreated({id: 4, blogId: 3, title: "Charlie Post 1"});

      var tuples = Blog.where({userId: 1}).join(BlogPost).all();

      expect(tuples.length).toBe(3);
      expect(tuples[0].left).toBe(blog1);
      expect(tuples[0].right).toBe(post1);
      expect(tuples[1].left).toBe(blog1);
      expect(tuples[1].right).toBe(post2);
      expect(tuples[2].left).toBe(blog3);
      expect(tuples[2].right).toBe(post4);
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

    function subscribe(join) {
      if (subscriptions) {
        subscriptions.destroy();
      } else {
        subscriptions = new Monarch.Util.SubscriptionBundle();
      }

      subscriptions.add(join.onInsert(insertCallback));
      subscriptions.add(join.onUpdate(updateCallback));
      subscriptions.add(join.onRemove(removeCallback));
      return join;
    }

    describe("insert events", function() {
      it("triggers insert events when a tuple in either operand is inserted", function() {
        // inserts into right
        subscribe(Blog.join(BlogPost));
        var blog1 = Blog.remotelyCreated({id: 1, userId: 1, title: "Alpha"});
        var post1 = BlogPost.remotelyCreated({id: 1, blogId: 1, title: "Alpha Post 1"});
        expect(insertCallback).toHaveBeenCalled();
        var composite = insertCallback.arg(0);
        expect(composite.left).toBe(blog1);
        expect(composite.right).toBe(post1);
        expect(insertCallback.arg(1)).toBe(0);
        insertCallback.reset();

        // inserts into left
        var post2 = BlogPost.remotelyCreated({id: 2, blogId: 2, title: "Bravo Post 1"});
        expect(insertCallback).not.toHaveBeenCalled();
        var blog2 = Blog.remotelyCreated({id: 2, userId: 1, title: "Bravo"});
        expect(insertCallback).toHaveBeenCalled();
        var composite = insertCallback.arg(0);
        expect(composite.left).toBe(blog2);
        expect(composite.right).toBe(post2);
        expect(insertCallback.arg(1)).toBe(1);
        insertCallback.reset();

        Blog.remotelyCreated({id: 3, userId: 1, title: "Charlie"});
        expect(insertCallback).not.toHaveBeenCalled();
      });

      it("triggers insert events when a tuple is updated in an operand in a way that causes it to be in the join when it wasn't previously", function() {
        var blog1 = Blog.remotelyCreated({id: 1, userId: 1, title: "Alpha"});
        var post1 = BlogPost.remotelyCreated({id: 1, blogId: 2, title: "Alpha Post 1"});
        var post2 = BlogPost.remotelyCreated({id: 2, blogId: 3, title: "Alpha Post 1"});

        subscribe(Blog.join(BlogPost));

        post1.remotelyUpdated({blogId: 1});

        expect(insertCallback).toHaveBeenCalled();
        var composite = insertCallback.arg(0);
        expect(composite.left).toBe(blog1);
        expect(composite.right).toBe(post1);
        expect(updateCallback).not.toHaveBeenCalled();
        insertCallback.reset();

        subscribe(BlogPost.join(Blog));

        post2.remotelyUpdated({blogId: 1});

        expect(insertCallback).toHaveBeenCalled();
        var composite = insertCallback.arg(0);
        expect(composite.left).toBe(post2);
        expect(composite.right).toBe(blog1);
        expect(updateCallback).not.toHaveBeenCalled();
        insertCallback.reset();
      });
    });
    
    describe("update events", function() {
      it("triggers update events when tuples in either operand are updated in a way that does not affect their membership in the join", function() {
        // updates on the right
        var blog1 = Blog.remotelyCreated({id: 1, userId: 1, title: "Alpha"});
        var blog2 = Blog.remotelyCreated({id: 2, userId: 1, title: "Bravo"});
        var blog3 = Blog.remotelyCreated({id: 3, userId: 2, title: "Charlie"});
        var blog4 = Blog.remotelyCreated({id: 4, userId: 1, title: "Delta"}); // empty
        var post1 = BlogPost.remotelyCreated({id: 1, blogId: 1, title: "Alpha"});
        var post2 = BlogPost.remotelyCreated({id: 2, blogId: 1, title: "Bravo"});
        var post3 = BlogPost.remotelyCreated({id: 3, blogId: 1, title: "Charlie"});
        var post4 = BlogPost.remotelyCreated({id: 4, blogId: 2, title: "Alpha"});
        var post5 = BlogPost.remotelyCreated({id: 5, blogId: 2, title: "Bravo"});
        var post6 = BlogPost.remotelyCreated({id: 6, blogId: 3, title: "Alpha"});

        var join = subscribe(Blog.where({userId: 1}).join(BlogPost));
        var expectedTuple = join.at(2);
        expect(expectedTuple.left).toBe(blog1);
        expect(expectedTuple.right).toBe(post3);

        post3.remotelyUpdated({title: "Alpha 1"});

        expect(updateCallback).toHaveBeenCalled();
        expect(updateCallback.arg(0)).toBe(expectedTuple);
        expect(updateCallback.arg(1)).toEqual({
          title: {
            oldValue: "Charlie",
            newValue: "Alpha 1",
            column: BlogPost.title
          }
        });
        expect(updateCallback.arg(2)).toBe(1);
        expect(updateCallback.arg(3)).toBe(2);
        updateCallback.reset();

        post6.remotelyUpdated({title: "Alpha 1"});
        expect(updateCallback).not.toHaveBeenCalled();

        // left operand
        blog2.remotelyUpdated({title: "0 Alpha"});
        var expectedChangeset = {
          title: {
            oldValue: "Bravo",
            newValue: "0 Alpha",
            column: Blog.title
          }
        };

        expect(updateCallback.callCount).toBe(2);
        var tuple1 = updateCallback.argsForCall[0][0];
        expect(tuple1.left).toBe(blog2);
        expect(tuple1.right).toBe(post4);
        expect(updateCallback.argsForCall[0][1]).toEqual(expectedChangeset);
        expect(updateCallback.argsForCall[0][2]).toBe(0); // new index
        expect(updateCallback.argsForCall[0][3]).toBe(3); // old index

        var tuple2 = updateCallback.argsForCall[1][0];
        expect(tuple2.left).toBe(blog2);
        expect(tuple2.right).toBe(post5);
        expect(updateCallback.argsForCall[1][1]).toEqual(expectedChangeset);
        expect(updateCallback.argsForCall[1][2]).toBe(1); // new index
        expect(updateCallback.argsForCall[1][3]).toBe(4); // old index

        updateCallback.reset();

        blog4.remotelyUpdated({title: "Echo"});

        expect(updateCallback).not.toHaveBeenCalled();
      });
    });

    describe("remove events", function() {
      var blog1, blog2, post1, post2, post3, post4;
      beforeEach(function() {
        blog1 = Blog.remotelyCreated({id: 1, userId: 1, title: "Alpha"});
        blog2 = Blog.remotelyCreated({id: 2, userId: 1, title: "Alpha"});
        post1 = BlogPost.remotelyCreated({id: 1, blogId: 1, title: "Alpha"});
        post2 = BlogPost.remotelyCreated({id: 2, blogId: 1, title: "Bravo"});
        post3 = BlogPost.remotelyCreated({id: 3, blogId: 1, title: "Bravo"});
        post4 = BlogPost.remotelyCreated({id: 4, blogId: 3, title: "Charlie"});
      });

      it("triggers remove events if a tuple is removed from an operand", function() {
        var join = subscribe(Blog.join(BlogPost));
        var expectedTuple = join.at(1);
        expect(expectedTuple.left).toBe(blog1);
        expect(expectedTuple.right).toBe(post2);

        // right operand
        post2.remotelyDestroyed();
        expect(removeCallback).toHaveBeenCalled();
        expect(removeCallback.arg(0)).toBe(expectedTuple);
        expect(removeCallback.arg(1)).toBe(1);
        removeCallback.reset();

        post4.remotelyDestroyed();
        expect(removeCallback).not.toHaveBeenCalled();

        // left operand
        var expectedTuple1 = join.at(0);
        var expectedTuple2 = join.at(1);
        expect(expectedTuple1.left).toBe(blog1);
        expect(expectedTuple1.right).toBe(post1);
        expect(expectedTuple2.left).toBe(blog1);
        expect(expectedTuple2.right).toBe(post3);

        blog1.remotelyDestroyed();
        expect(removeCallback.callCount).toBe(2);
        expect(removeCallback.argsForCall[0][0]).toBe(expectedTuple1);
        expect(removeCallback.argsForCall[0][1]).toBe(0);
        expect(removeCallback.argsForCall[1][0]).toBe(expectedTuple2);
        expect(removeCallback.argsForCall[1][1]).toBe(0);
        removeCallback.reset();

        blog2.remotelyDestroyed();
        expect(removeCallback).not.toHaveBeenCalled();
      });

      it("triggers remove events if a tuple is updated to no longer match the predicate", function() {
        // right operand
        var join1 = subscribe(Blog.join(BlogPost));
        var expectedTuple = join1.at(1);
        expect(expectedTuple.left).toBe(blog1);
        expect(expectedTuple.right).toBe(post2);
        
        post2.remotelyUpdated({blogId: 100});
        expect(removeCallback).toHaveBeenCalled();
        expect(removeCallback.arg(0)).toBe(expectedTuple);
        expect(removeCallback.arg(1)).toBe(1);
        removeCallback.reset();

        // left operand
        var join2 = subscribe(BlogPost.join(Blog));
        expectedTuple = join2.at(1);
        expect(expectedTuple.left).toBe(post3);
        expect(expectedTuple.right).toBe(blog1);

        post3.remotelyUpdated({blogId: 100});
        expect(removeCallback).toHaveBeenCalled();
        expect(removeCallback.arg(0)).toBe(expectedTuple);
        expect(removeCallback.arg(1)).toBe(1);
        removeCallback.reset();
      });
    });

    describe("deactivation", function() {
      it("removes subscriptions on the operands", function() {
        expect(BlogPost.hasSubscriptions()).toBeFalsy();
        expect(Blog.hasSubscriptions()).toBeFalsy();

        subscribe(Blog.join(BlogPost));

        expect(BlogPost.hasSubscriptions()).toBeTruthy();
        expect(Blog.hasSubscriptions()).toBeTruthy();

        subscriptions.destroy();

        expect(BlogPost.hasSubscriptions()).toBeFalsy();
        expect(Blog.hasSubscriptions()).toBeFalsy();
      });
    });
  });
});

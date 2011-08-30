describe("Monarch.Relations.Projection", function() {

  beforeEach(function() {
    User = new JS.Class('User', Monarch.Record);
    User.columns({
      premium: 'boolean'
    });

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

  describe("#all", function() {
    it("extracts records corresponding to the projected table from the underlying composite tuples", function() {
      User.remotelyCreated({id: 1, premium: true});
      User.remotelyCreated({id: 2, premium: false});
      Blog.remotelyCreated({id: 1, userId: 1, title: "Alpha"});
      Blog.remotelyCreated({id: 2, userId: 1, title: "Bravo"});
      Blog.remotelyCreated({id: 3, userId: 2, title: "Charlie"});
      var post1 = BlogPost.remotelyCreated({id: 1, blogId: 1, title: "Alpha"});
      var post2 = BlogPost.remotelyCreated({id: 2, blogId: 1, title: "Bravo"});
      var post3 = BlogPost.remotelyCreated({id: 3, blogId: 2, title: "Charlie"});
      BlogPost.remotelyCreated({id: 4, blogId: 3, title: "Delta"});

      var records = User.where({premium: true}).join(Blog).joinThrough(BlogPost).all();
      expect(records).toEqual([post1, post2, post3]);
    });
  });

  describe("events", function() {
    var projection, insertCallback, updateCallback, removeCallback, subscriptions;

    beforeEach(function() {
      projection = Blog.where({userId: 1}).join(BlogPost).project(Blog);
      subscriptions = new Monarch.Util.SubscriptionBundle();
      insertCallback = jasmine.createSpy('insertCallback');
      updateCallback = jasmine.createSpy('updateCallback');
      removeCallback = jasmine.createSpy('removeCallback');
      subscriptions.add(projection.onInsert(insertCallback));
      subscriptions.add(projection.onUpdate(updateCallback));
      subscriptions.add(projection.onRemove(removeCallback));
    });

    describe("insert", function() {
      it("triggers insert events when composites are inserted into the operand, but only if the record is not already a member of the relation", function() {
        var blog = Blog.remotelyCreated({id: 1, title: "Alpha", userId: 1});
        BlogPost.remotelyCreated({id: 1, blogId: 1, title: "Alpha"});

        expect(insertCallback).toHaveBeenCalled();
        expect(insertCallback.arg(0)).toBe(blog);
        expect(insertCallback.arg(1)).toBe(0);
        insertCallback.reset();

        BlogPost.remotelyCreated({id: 2, blogId: 1, title: "Bravo"});
        expect(insertCallback).not.toHaveBeenCalled();
      });
    });

    describe("update", function() {
      it("triggers update events if a record in the projection is updated", function() {
        var blog1 = Blog.remotelyCreated({id: 1, title: "Alpha", userId: 1});
        var blog2 = Blog.remotelyCreated({id: 2, title: "Bravo", userId: 1});
        var post1 = BlogPost.remotelyCreated({id: 1, blogId: 1, title: "Alpha"});
        var post2 = BlogPost.remotelyCreated({id: 2, blogId: 2, title: "Bravo"});
        var post3 = BlogPost.remotelyCreated({id: 3, blogId: 1, title: "Charlie"});

        post1.remotelyUpdated({title: "Echo"});
        expect(updateCallback).not.toHaveBeenCalled();

        blog1.remotelyUpdated({title: "Zulu"});
        expect(updateCallback.callCount).toBe(1);
        expect(updateCallback.arg(0)).toBe(blog1);
        expect(updateCallback.arg(1)).toEqual({
          title: {
            oldValue: "Alpha",
            newValue: "Zulu",
            column: Blog.title
          }
        });
        expect(updateCallback.arg(2)).toBe(1);
        expect(updateCallback.arg(3)).toBe(0);
      });
    });

    describe("remove", function() {
      it("triggers remove events when the last composite containing a projected record is removed from the operand", function() {
        var blog = Blog.remotelyCreated({id: 1, title: "Alpha", userId: 1});
        var post1 = BlogPost.remotelyCreated({id: 1, blogId: 1, title: "Alpha"});
        var post2 = BlogPost.remotelyCreated({id: 2, blogId: 1, title: "Bravo"});

        post1.remotelyDestroyed();
        expect(removeCallback).not.toHaveBeenCalled();

        post2.remotelyDestroyed();
        expect(removeCallback).toHaveBeenCalled();
        expect(removeCallback.arg(0)).toBe(blog);
        expect(removeCallback.arg(1)).toBe(0);
      });
    });
  });

  describe("#isEqual(other)", function() {
    it("determines structural equality", function() {
      var projection1 = Blog.where({userId: 1}).joinThrough(BlogPost);
      var projection2 = Blog.where({userId: 1}).joinThrough(BlogPost);
      expect(projection1).toEqual(projection2);
    });
  });
});
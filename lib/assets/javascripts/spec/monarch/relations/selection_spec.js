//= require spec/spec_helper

describe("Monarch.Relations.Selection", function() {
  var post1, post2, post3, post4;

  beforeEach(function() {
    BlogPost = new JS.Class('BlogPost', Monarch.Record);
    BlogPost.columns({
      blogId: 'integer',
      title: 'string'
    });
    BlogPost.defaultOrderBy('title');

    post1 = BlogPost.remotelyCreated({id: 1, blogId: 1, title: "Beta"});
    post2 = BlogPost.remotelyCreated({id: 2, blogId: 1, title: "Charlie"});
    post3 = BlogPost.remotelyCreated({id: 3, blogId: 2, title: "Charlie"});
    post4 = BlogPost.remotelyCreated({id: 4, blogId: 3, title: "Delta"});
  });

  describe("#all()", function() {
    it("returns tuples that match the predicate", function() {
      expect(BlogPost.where({blogId: 1}).all()).toEqual([post1, post2]);
      expect(BlogPost.where({title: "Charlie"}).all()).toEqual([post2, post3]);
      expect(BlogPost.where({blogId: 2, title: "Charlie"}).all()).toEqual([post3]);
      expect(BlogPost.where(BlogPost.blogId.eq(2).and({title: "Charlie"})).all()).toEqual([post3]);
    });
  });

  describe("events", function() {
    var selection, insertCallback, updateCallback, removeCallback, subscriptions;

    beforeEach(function() {
      selection = BlogPost.where({blogId: 1});
      subscriptions = new Monarch.Util.SubscriptionBundle();
      insertCallback = jasmine.createSpy('insertCallback');
      updateCallback = jasmine.createSpy('updateCallback');
      removeCallback = jasmine.createSpy('removeCallback');

      subscriptions.add(selection.onInsert(insertCallback));
      subscriptions.add(selection.onUpdate(updateCallback));
      subscriptions.add(selection.onRemove(removeCallback));
    });

    describe("insert events", function() {
      it("triggers them if an event on the underlying relation leads to insertion", function() {
        var newPost = BlogPost.remotelyCreated({id: 100, blogId: 1});
        expect(insertCallback).toHaveBeenCalled();
        expect(insertCallback.arg(0)).toBe(newPost);
        expect(insertCallback.arg(1)).toBe(2);
        expect(updateCallback).not.toHaveBeenCalled();
        insertCallback.reset();
        
        post3.remotelyUpdated({blogId: 1});
        expect(insertCallback).toHaveBeenCalled();
        expect(insertCallback.arg(0)).toBe(post3);
        expect(insertCallback.arg(1)).toBe(2);
        expect(updateCallback).not.toHaveBeenCalled();
      });
    });

    describe("update events", function() {
      it("triggers them if a tuple in the selection is updated", function() {
        post2.remotelyUpdated({title: "Alpha"});
        expect(updateCallback).toHaveBeenCalled();
        expect(updateCallback.arg(0)).toBe(post2);
        expect(updateCallback.arg(1)).toEqual({
          title: {
            oldValue: "Charlie",
            newValue: "Alpha",
            column: BlogPost.title
          }
        });
        expect(updateCallback.arg(2)).toBe(0);
        expect(updateCallback.arg(3)).toBe(1);
        expect(insertCallback).not.toHaveBeenCalled();
        updateCallback.reset();

        post3.remotelyUpdated({title: "Omega"});
        expect(updateCallback).not.toHaveBeenCalled();
        expect(removeCallback).not.toHaveBeenCalled();
      });
    });

    describe("remove events", function() {
      it("triggers them if a tuple in the selection is removed", function() {
        post2.remotelyUpdated({blogId: 100, title: "X-Ray"});
        expect(removeCallback).toHaveBeenCalled();
        expect(removeCallback.arg(0)).toBe(post2);
        expect(removeCallback.arg(1)).toBe(1);
        removeCallback.reset();

        post1.remotelyDestroyed();
        expect(removeCallback).toHaveBeenCalled();
        expect(removeCallback.arg(0)).toBe(post1);
        expect(removeCallback.arg(1)).toBe(0);
      });

      it("triggers them correctly even if the underlying cause of the removal was an order-disrupting update", function() {
        var selection = BlogPost.where({title: "Charlie"}).where({blogId: 1});
        expect(selection.contains(post2)).toBeTruthy();
        selection.onRemove(removeCallback);

        post2.remotelyUpdated({title: "X-Ray"});
        expect(removeCallback).toHaveBeenCalled();
        expect(removeCallback.arg(0)).toBe(post2);
        expect(removeCallback.arg(1)).toBe(0);
      });
    });

    describe("deactivation", function() {
      it("destroys subscriptions on the operand when the last of its subscriptions is removed", function() {
        expect(selection.isActive).toBeTruthy();
        expect(BlogPost.hasSubscriptions()).toBeTruthy();
        subscriptions.destroy();
        expect(selection.isActive).toBeFalsy();
        expect(BlogPost.hasSubscriptions()).toBeFalsy();
      });
    });
  });

  describe("#contains(tuple)", function() {
    it("works even when the relation is not active", function() {
      expect(BlogPost.where({blogId: 1}).contains(post2)).toBeTruthy();
    });
  });

  describe("#indexOf(tuple)", function() {
    it("works even when the relation is not active", function() {
      expect(BlogPost.where({blogId: 1}).indexOf(post2)).toBe(1);
    });
  });

  describe("#isEqual(other)", function() {
    it("returns true if the other selection is structurally equivalent", function() {
      expect(BlogPost.where({blogId: 1}).isEqual(BlogPost.where({blogId: 1}))).toBeTruthy();
      expect(BlogPost.where({blogId: 1}).isEqual(BlogPost.where({blogId: 2}))).toBeFalsy();
      expect(BlogPost.where({blogId: 1}).isEqual(null)).toBeFalsy();
    });
  });
});

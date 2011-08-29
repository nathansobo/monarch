//= require spec/spec_helper

describe("Monarch.Relations.Table", function() {
  describe("events", function() {
    var subscriptions, insertCallback, updateCallback, removeCallback;

    beforeEach(function() {
      BlogPost = new JS.Class('BlogPost', Monarch.Record);
      BlogPost.columns({
        blogId: 'integer',
        title: 'string',
        body: 'string'
      });
      BlogPost.defaultOrderBy('blogId');

      insertCallback = jasmine.createSpy('insertCallback');
      updateCallback = jasmine.createSpy('updateCallback');
      removeCallback = jasmine.createSpy('removeCallback');

      subscriptions = new Monarch.Util.SubscriptionBundle();
      subscriptions.add(BlogPost.onInsert(insertCallback));
      subscriptions.add(BlogPost.onUpdate(updateCallback));
      subscriptions.add(BlogPost.onRemove(removeCallback));
    });

    it("triggers events when one of its records is created, updated, or destroyed", function() {
      BlogPost.remotelyCreated({id: 1, blogId: 1, title: "Title", body: "Body"});
      expect(insertCallback).toHaveBeenCalled();
      expect(updateCallback).not.toHaveBeenCalled();
      var post = insertCallback.arg(0);
      expect(insertCallback.arg(1)).toBe(0);

      BlogPost.remotelyCreated({id: 1, blogId: 2, title: "Title 2", body: "Body 2"});
      expect(insertCallback).toHaveBeenCalled();
      expect(insertCallback.arg(1)).toBe(1);

      post.remotelyUpdated({blogId: 3, title: "Title Prime"});
      expect(updateCallback).toHaveBeenCalled();
      expect(updateCallback.arg(0)).toBe(post);
      expect(updateCallback.arg(1)).toEqual({
        blogId: {
          newValue: 3,
          oldValue: 1,
          column: BlogPost.blogId
        },
        title: {
          newValue: "Title Prime",
          oldValue: "Title",
          column: BlogPost.title
        }
      });

      expect(updateCallback.arg(2)).toBe(1);
      expect(updateCallback.arg(3)).toBe(0);

      post.remotelyDestroyed();
      expect(removeCallback).toHaveBeenCalled();
      expect(removeCallback.arg(0)).toBe(post);
      expect(removeCallback.arg(1)).toBe(1);
    });

    it("always remains active, even if there are no subscriptions", function() {
      expect(BlogPost.hasSubscriptions()).toBeTruthy();
      subscriptions.destroy();
      expect(BlogPost.hasSubscriptions()).toBeFalsy();
      expect(BlogPost.table.isActive).toBeTruthy();
    });
  });

  describe("#defaultOrderBy", function() {
    it("sorts records by the given specifications", function() {
      BlogPost = new JS.Class('BlogPost', Monarch.Record);
      BlogPost.columns({
        blogId: 'integer',
        title: 'string'
      });
      BlogPost.defaultOrderBy('blogId asc', 'title desc');

      // created in a random order to ensure correct order is not accidental
      var post5 = BlogPost.remotelyCreated({id: 5, blogId: 3, title: "A"});
      var post1 = BlogPost.remotelyCreated({id: 1, blogId: 3, title: "A"});
      var post2 = BlogPost.remotelyCreated({id: 2, blogId: 2, title: "A"});
      var post4 = BlogPost.remotelyCreated({id: 4, blogId: 1, title: "B"});
      var post3 = BlogPost.remotelyCreated({id: 3, blogId: 1, title: "A"});

      expect(BlogPost.at(0)).toBe(post4);
      expect(BlogPost.at(1)).toBe(post3);
      expect(BlogPost.at(2)).toBe(post2);
      expect(BlogPost.at(3)).toBe(post1);
      expect(BlogPost.at(4)).toBe(post5);

      // position is updated when order-critical fields change
      post5.remotelyUpdated({blogId: 1});
      expect(BlogPost.indexOf(post5)).toBe(2);
    });
  });
});
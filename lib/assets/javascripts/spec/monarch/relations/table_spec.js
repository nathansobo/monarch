//= require spec/spec_helper

describe("Monarch.Relations.Table", function() {
  describe("events", function() {
    var insertCallback, updateCallback, removeCallback;

    beforeEach(function() {
      BlogPost = new JS.Class('BlogPost', Monarch.Record);
      BlogPost.columns({
        blogId: 'integer',
        title: 'string',
        body: 'string'
      });

      insertCallback = jasmine.createSpy('insertCallback');
      updateCallback = jasmine.createSpy('updateCallback');
      removeCallback = jasmine.createSpy('removeCallback');

      BlogPost.onInsert(insertCallback);
      BlogPost.onUpdate(updateCallback);
      BlogPost.onRemove(removeCallback);
    });

    it("triggers events when one of its records is created, updated, or destroyed", function() {
      BlogPost.remotelyCreated({id: 1, blogId: 1, title: "Title", body: "Body"});
      expect(insertCallback).toHaveBeenCalled();
      expect(updateCallback).not.toHaveBeenCalled();
      var post = insertCallback.mostRecentCall.args[0];

      post.remotelyUpdated({blogId: 2, title: "Title Prime"});
      expect(updateCallback).toHaveBeenCalled();
      expect(updateCallback.mostRecentCall.args[0]).toBe(post);
      expect(updateCallback.mostRecentCall.args[1]).toEqual({
        blogId: {
          newValue: 2,
          oldValue: 1
        },
        title: {
          newValue: "Title Prime",
          oldValue: "Title"
        }
      });

      post.remotelyDestroyed();
      expect(removeCallback).toHaveBeenCalled();
      expect(removeCallback.mostRecentCall.args[0]).toBe(post);
    });
  });

  describe("#orderBy", function() {
    it("sorts records by the given specifications", function() {
      BlogPost = new JS.Class('BlogPost', Monarch.Record);
      BlogPost.columns({
        blogId: 'integer',
        title: 'string'
      });
      BlogPost.orderBy('blogId asc', 'title desc');

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
    });
  });
});
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
});
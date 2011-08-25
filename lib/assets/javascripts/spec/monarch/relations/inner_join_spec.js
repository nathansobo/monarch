//= require spec/spec_helper

describe("Monarch.Relations.InnerJoin", function() {
  beforeEach(function() {
    Blog = new JS.Class('Blog', Monarch.Record);
    Blog.columns({
      userId: 'integer',
      title: 'string'
    });

    BlogPost = new JS.Class('BlogPost', Monarch.Record);
    BlogPost.columns({
      blogId: 'integer',
      title: 'string'
    });
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
      var blog2 = Blog.remotelyCreated({id: 2, userId: 2, title: "Beta"});
      var blog3 = Blog.remotelyCreated({id: 3, userId: 1, title: "Charlie"});
      var post1 = BlogPost.remotelyCreated({id: 1, blogId: 1, title: "Alpha Post 1"});
      var post2 = BlogPost.remotelyCreated({id: 2, blogId: 1, title: "Alpha Post 2"});
      var post3 = BlogPost.remotelyCreated({id: 3, blogId: 2, title: "Beta Post 1"});
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
    var selection, insertCallback, updateCallback, removeCallback;

    beforeEach(function() {
      insertCallback = jasmine.createSpy('insertCallback');
      updateCallback = jasmine.createSpy('updateCallback');
      removeCallback = jasmine.createSpy('removeCallback');
    });

    function subscribe(join) {
      join.onInsert(insertCallback);
      join.onUpdate(updateCallback);
      join.onRemove(removeCallback);
      return join;
    }

    describe("insert events", function() {
      it("triggers insert events when a tuple in an operand is inserted or updated", function() {
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
        var post2 = BlogPost.remotelyCreated({id: 2, blogId: 2, title: "Beta Post 1"});
        expect(insertCallback).not.toHaveBeenCalled();
        var blog2 = Blog.remotelyCreated({id: 2, userId: 1, title: "Beta"});
        expect(insertCallback).toHaveBeenCalled();
        var composite = insertCallback.arg(0);
        expect(composite.left).toBe(blog2);
        expect(composite.right).toBe(post2);
        expect(insertCallback.arg(1)).toBe(1);
        insertCallback.reset();

        Blog.remotelyCreated({id: 3, userId: 1, title: "Charlie"});
        expect(insertCallback).not.toHaveBeenCalled();
      });
    });
  });
});

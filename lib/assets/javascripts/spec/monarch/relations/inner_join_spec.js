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
});

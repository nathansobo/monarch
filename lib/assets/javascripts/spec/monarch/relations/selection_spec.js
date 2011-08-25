//= require spec/spec_helper

describe("Monarch.Relations.Selection", function() {
  var post1, post2, post3, post4;

  beforeEach(function() {
    BlogPost = new JS.Class('BlogPost', Monarch.Record);
    BlogPost.columns({
      blogId: 'integer',
      title: 'string'
    });

    post1 = BlogPost.remotelyCreated({id: 1, blogId: 1, title: "Foo"});
    post2 = BlogPost.remotelyCreated({id: 2, blogId: 1, title: "Bar"});
    post3 = BlogPost.remotelyCreated({id: 3, blogId: 2, title: "Bar"});
    post4 = BlogPost.remotelyCreated({id: 4, blogId: 3, title: "Baz"});
  });

  describe("#all()", function() {
    it("returns tuples that match the predicate", function() {
      expect(BlogPost.where({blogId: 1}).all()).toEqual([post1, post2]);
      expect(BlogPost.where({title: "Bar"}).all()).toEqual([post2, post3]);
      expect(BlogPost.where({blogId: 2, title: "Bar"}).all()).toEqual([post3]);
      expect(BlogPost.where(BlogPost.blogId.eq(2).and({title: "Bar"})).all()).toEqual([post3]);
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
});
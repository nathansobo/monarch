//= require spec/spec_helper

describe("Monarch.Relations.Selection", function() {
  beforeEach(function() {
    BlogPost = new JS.Class('BlogPost', Monarch.Record);
    BlogPost.columns({
      blogId: 'integer',
      title: 'string'
    });
  });

  describe("#all()", function() {
    it("returns tuples that match the predicate", function() {
      var post1 = BlogPost.remotelyCreated({id: 1, blogId: 1, title: "Foo"});
      var post2 = BlogPost.remotelyCreated({id: 2, blogId: 1, title: "Bar"});
      var post3 = BlogPost.remotelyCreated({id: 3, blogId: 2, title: "Bar"});
      var post4 = BlogPost.remotelyCreated({id: 4, blogId: 3, title: "Baz"});

//      expect(BlogPost.where({blogId: 1}).all()).toEqual([post1, post2]);
//      expect(BlogPost.where({title: "Bar"}).all()).toEqual([post2, post3]);
//      expect(BlogPost.where({blogId: 2, title: "Bar"}).all()).toEqual([post3]);
      expect(BlogPost.where(BlogPost.blogId.eq(2).and({title: "Bar"})).all()).toEqual([post3]);
    });
  });
});
describe("Monarch.Relations.Limit", function() {
  beforeEach(function() {
    BlogPost = new JS.Class('BlogPost', Monarch.Record);
    BlogPost.columns({
      title: "string"
    });
    BlogPost.defaultOrderBy('title');
  });

  describe("#all()", function() {
    it("returns up to 'count' records", function() {
      var post1 = BlogPost.remotelyCreated({id: 1, title: "Alpha"});
      var post2 = BlogPost.remotelyCreated({id: 2, title: "Bravo"});
      var post3 = BlogPost.remotelyCreated({id: 3, title: "Charlie"});

      expect(BlogPost.limit(2).all()).toEqual([post1, post2]);
      expect(BlogPost.limit(4).all()).toEqual([post1, post2, post3]);
    });
  });
});
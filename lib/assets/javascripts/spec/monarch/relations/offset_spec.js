describe("Monarch.Relations.Offset", function() {
  beforeEach(function() {
    BlogPost = new JS.Class('BlogPost', Monarch.Record);
    BlogPost.columns({
      title: "string"
    });
    BlogPost.defaultOrderBy('title');
  });

  describe("#all()", function() {
    it("returns the records from the operand with the first 'count' discarded", function() {
      var post1 = BlogPost.remotelyCreated({id: 1, title: "Alpha"});
      var post2 = BlogPost.remotelyCreated({id: 2, title: "Bravo"});
      var post3 = BlogPost.remotelyCreated({id: 3, title: "Charlie"});
      var post4 = BlogPost.remotelyCreated({id: 4, title: "Delta"});

      expect(BlogPost.offset(2).all()).toEqual([post3, post4]);
    });
  });
});
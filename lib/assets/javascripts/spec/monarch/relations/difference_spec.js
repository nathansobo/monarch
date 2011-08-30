describe("Monarch.Relations.Difference", function() {
  beforeEach(function() {
    BlogPost = new JS.Class('BlogPost', Monarch.Record);
    BlogPost.columns({
      public: 'boolean',
      blogId: 'integer',
      title: 'string'
    });
    BlogPost.defaultOrderBy('title');
  });

  describe("#all()", function() {
    it("returns relations in the left operand that aren't in the right", function() {
      var post1 = BlogPost.remotelyCreated({id: 1, title: "Alpha", blogId: 1, public: false});
      var post2 = BlogPost.remotelyCreated({id: 2, title: "Bravo", blogId: 1, public: false});
      var post3 = BlogPost.remotelyCreated({id: 3, title: "Charlie", blogId: 1, public: true});
      var post4 = BlogPost.remotelyCreated({id: 4, title: "Delta", blogId: 2, public: true});

      var records = BlogPost.where({blogId: 1}).difference(BlogPost.where({public: true})).all();
      expect(records).toEqual([post1, post2]);
    });
  });
});
describe("Monarch.Relations.Union", function() {
  beforeEach(function() {
    BlogPost = new JS.Class('BlogPost', Monarch.Record);
    BlogPost.columns({
      blogId: 'integer',
      public: 'boolean',
      title: 'string'
    });
    BlogPost.defaultOrderBy('title');
  });

  describe("#all", function() {
    it("returns the union of the left and the right", function() {
      var post1 = BlogPost.remotelyCreated({id: 1, blogId: 1, public: true, title: "Alpha"});
      var post2 = BlogPost.remotelyCreated({id: 2, blogId: 1, public: false, title: "Bravo"});
      var post3 = BlogPost.remotelyCreated({id: 3, blogId: 1, public: true, title: "Delta"});
      var post4 = BlogPost.remotelyCreated({id: 4, blogId: 2, public: false, title: "Echo"});
      var post5 = BlogPost.remotelyCreated({id: 5, blogId: 2, public: true, title: "Foxtrot"});
      var post6 = BlogPost.remotelyCreated({id: 6, blogId: 2, public: false, title: "Golf"});
      var records = BlogPost.where({blogId: 1}).union(BlogPost.where({public: true})).all();
      expect(records).toEqual([post1, post2, post3, post5])
    });
  });

  describe("#isEqual(other)", function() {
    it("determines structural equality", function() {
      var union1 = BlogPost.where({blogId: 1}).union(BlogPost.where({blogId: 2}));
      var union2 = BlogPost.where({blogId: 1}).union(BlogPost.where({blogId: 2}));
      var union3 = BlogPost.where({blogId: 1}).union(BlogPost.where({blogId: 3}));

      expect(union1).toEqual(union2);
      expect(union1).not.toEqual(union3);
    });
  });
});
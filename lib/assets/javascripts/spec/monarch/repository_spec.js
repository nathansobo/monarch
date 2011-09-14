describe("Monarch.Repository", function() {
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

  describe(".update(recordsHash)", function() {
    it("takes a records hash (from the server) and creates / updates its contents locally", function() {
      var existingBlog = Blog.remotelyCreated({id: 1, title: "Alpha"});
      var existingPost = BlogPost.remotelyCreated({id: 22, title: "Bravo"});

      Monarch.Repository.update({
        blogs: {
          1: {
            user_id: 1,
            title: "Charlie"
          },
          33: {
            user_id: 2,
            title: "Delta"
          }
        },
        blog_posts: {
          1: {
            blog_id: 1,
            title: "Zulu"
          },
          22: {
            blog_id: 1,
            title: "Uniform"
          }
        }
      });


      var newBlog = Blog.find(33);
      expect(newBlog).toBeDefined();
      expect(newBlog.title()).toBe("Delta");
      expect(newBlog.userId()).toBe(2);

      expect(existingBlog.title()).toBe("Charlie");
      expect(existingBlog.userId()).toBe(1);

      expect(BlogPost.find(1).title()).toBe("Zulu");
      expect(BlogPost.find(1).blogId()).toBe(1);

      expect(existingPost.title()).toBe("Uniform");
      expect(existingPost.blogId()).toBe(1);
    });
  });
});
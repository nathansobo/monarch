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

  describe(".update(hashOrArray)", function() {
    describe("when given a hash of records", function() {
      it("takes a records hash (from the server) and creates / updates its contents locally", function() {
        var existingBlog = Blog.created({id: 1, title: "Alpha"});
        var existingPost = BlogPost.created({id: 22, title: "Bravo"});

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

    describe("when given an array of commands", function() {
      it("executes an array commands against the repository, if their effects are not redundant", function() {
        var blog1 = Blog.created({id: 1, title: "Charlie"});
        var post1 = BlogPost.created({id: 1, title: "Charlie", blogId: 1});
        Blog.created({id: 2, title: "Echo"});
        BlogPost.created({id: 2, title: "Echo", blogId: 2});

        var blogInsertCallback = jasmine.createSpy('blogInsertCallback');
        var blogUpdateCallback = jasmine.createSpy('blogUpdateCallback');
        var blogRemoveCallback = jasmine.createSpy('blogRemoveCallback');

        Blog.onInsert(blogInsertCallback);
        Blog.onUpdate(blogUpdateCallback);
        Blog.onRemove(blogRemoveCallback);

        var postInsertCallback = jasmine.createSpy('postInsertCallback');
        var postUpdateCallback = jasmine.createSpy('postUpdateCallback');
        var postRemoveCallback = jasmine.createSpy('postRemoveCallback');

        BlogPost.onInsert(postInsertCallback);
        BlogPost.onUpdate(postUpdateCallback);
        BlogPost.onRemove(postRemoveCallback);

        Monarch.Repository.update([
          ['create', 'blogs', { id: 3, user_id: 1, title: "Alpha" }],
          ['create', 'blogs', { id: 1, user_id: 1, title: "Discarded" }],
          ['create', 'blog_posts', { id: 3, blog_id: 1, title: "Alpha" }],
          ['update', 'blogs', 1, { title: "Uniform"}],
          ['update', 'blog_posts', 1, { title: "Zulu", blog_id: 2}],
          ['destroy', 'blogs', 2],
          ['destroy', 'blogs', 2],
          ['destroy', 'blog_posts', 2]
        ]);

        expect(blogInsertCallback.callCount).toBe(1);
        expect(postInsertCallback.callCount).toBe(1);
        expect(blogUpdateCallback.callCount).toBe(1);
        expect(postUpdateCallback.callCount).toBe(1);
        expect(blogRemoveCallback.callCount).toBe(1);
        expect(postRemoveCallback.callCount).toBe(1);

        var blog3 = Blog.find(3);
        expect(blog3).toBeDefined();
        expect(blog3.title()).toBe("Alpha");
        expect(blog3.userId()).toBe(1);

        var post3 = BlogPost.find(3);
        expect(post3).toBeDefined();
        expect(post3.title()).toBe("Alpha");
        expect(post3.blogId()).toBe(1);

        expect(blog1.title()).toBe("Uniform");
        expect(post1.title()).toBe("Zulu");
        expect(post1.blogId()).toBe(2);

        expect(Blog.find(2)).toBeUndefined();
        expect(BlogPost.find(2)).toBeUndefined();
      });

      it("can be called with a single command", function() {
        Monarch.Repository.update(['create', 'blogs', {id: 1, title: "Alpha"}]);
        expect(Blog.find(1)).toBeDefined();
      });
    });
  });

  describe(".pauseUpdates() and .resumeUpdates()", function() {
    it("defers all update operations while paused, and resumes them when the last pause call is matched with a resume call", function() {
      Monarch.Repository.pauseUpdates(); // first pause

      Monarch.Repository.update({
        blogs: {
          1: {
            title: "Alpha"
          }
        }
      });

      Monarch.Repository.pauseUpdates(); // second pause

      Monarch.Repository.update([
        ['create', 'blogs', { id: 2, title: "Bravo"}],
        ['create', 'blog_posts', { id: 1, title: "Alpha", blog_id: 1}]
      ]);

      Monarch.Repository.update([
        ['create', 'blogs', { id: 3, title: "Charlie"}]
      ]);

      Monarch.Repository.resumeUpdates(); // first resume

      expect(Blog.size()).toBe(0);
      expect(BlogPost.size()).toBe(0);

      Monarch.Repository.resumeUpdates(); // final resume, updates are processed

      expect(Blog.size()).toBe(3);
      expect(BlogPost.size()).toBe(1);

      // updates no longer paused
      Monarch.Repository.update([
        ['create', 'blogs', { id: 4, title: "Delta"}]
      ]);
      
      expect(Blog.size()).toBe(4);
    });
  });
});
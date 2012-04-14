describe "Monarch.Repository", ->
  [Blog, BlogPost] = []

  beforeEach ->
    class Blog extends Monarch.Record
      @extended(this)
      @columns
        userId: 'integer'
        title: 'string'

    class BlogPost extends Monarch.Record
      @extended(this)
      @columns
        blogId: 'integer'
        title: 'string'

  describe ".update(hashOrArray)", ->
    describe "when given a hash of records", ->
      it "takes a records hash (from the server) and creates / updates its contents locally", ->
        existingBlog = Blog.created(id: 1, title: "Alpha")
        existingPost = BlogPost.created(id: 22, title: "Bravo")

        Monarch.Repository.update
          Blog:
            1:
              userId: 1
              title: "Charlie"
            33:
              user_id: 2 # converts snake-case to camel case
              title: "Delta"
          BlogPost:
            1:
              blogId: 1
              title: "Zulu"
            22:
              blog_id: 1 # converts snake-case to camel case
              title: "Uniform"

        newBlog = Blog.find(33)
        expect(newBlog).toBeDefined()
        expect(newBlog.title()).toBe("Delta")
        expect(newBlog.userId()).toBe(2)

        expect(existingBlog.title()).toBe("Charlie")
        expect(existingBlog.userId()).toBe(1)

        expect(BlogPost.find(1).title()).toBe("Zulu")
        expect(BlogPost.find(1).blogId()).toBe(1)

        expect(existingPost.title()).toBe("Uniform")
        expect(existingPost.blogId()).toBe(1)

    describe "when given an array of commands", ->
      it "executes an array commands against the repository, if their effects are not redundant", ->
        blog1 = Blog.created(id: 1, title: "Charlie")
        post1 = BlogPost.created(id: 1, title: "Charlie", blogId: 1)
        Blog.created(id: 2, title: "Echo")
        BlogPost.created(id: 2, title: "Echo", blogId: 2)

        blogInsertCallback = jasmine.createSpy('blogInsertCallback')
        blogUpdateCallback = jasmine.createSpy('blogUpdateCallback')
        blogRemoveCallback = jasmine.createSpy('blogRemoveCallback')

        Blog.onInsert(blogInsertCallback)
        Blog.onUpdate(blogUpdateCallback)
        Blog.onRemove(blogRemoveCallback)

        postInsertCallback = jasmine.createSpy('postInsertCallback')
        postUpdateCallback = jasmine.createSpy('postUpdateCallback')
        postRemoveCallback = jasmine.createSpy('postRemoveCallback')

        BlogPost.onInsert(postInsertCallback)
        BlogPost.onUpdate(postUpdateCallback)
        BlogPost.onRemove(postRemoveCallback)

        Monarch.Repository.update([
          ['create', 'Blog',  id: 3, userId: 1, title: "Alpha" ],
          ['create', 'Blog',  id: 1, userId: 1, title: "Discarded" ],
          ['create', 'BlogPost',  id: 3, blogId: 1, title: "Alpha" ],
          ['update', 'Blog', 1,  title: "Uniform"],
          ['update', 'BlogPost', 1,  title: "Zulu", blogId: 2],
          ['destroy', 'Blog', 2],
          ['destroy', 'Blog', 2],
          ['destroy', 'BlogPost', 2]
        ])

        expect(blogInsertCallback.callCount).toBe(1)
        expect(postInsertCallback.callCount).toBe(1)
        expect(blogUpdateCallback.callCount).toBe(1)
        expect(postUpdateCallback.callCount).toBe(1)
        expect(blogRemoveCallback.callCount).toBe(1)
        expect(postRemoveCallback.callCount).toBe(1)

        blog3 = Blog.find(3)
        expect(blog3).toBeDefined()
        expect(blog3.title()).toBe("Alpha")
        expect(blog3.userId()).toBe(1)

        post3 = BlogPost.find(3)
        expect(post3).toBeDefined()
        expect(post3.title()).toBe("Alpha")
        expect(post3.blogId()).toBe(1)

        expect(blog1.title()).toBe("Uniform")
        expect(post1.title()).toBe("Zulu")
        expect(post1.blogId()).toBe(2)

        expect(Blog.find(2)).toBeUndefined()
        expect(BlogPost.find(2)).toBeUndefined()

      it "can be called with a single command", ->
        Monarch.Repository.update(['create', 'Blog', id: 1, title: "Alpha"])
        expect(Blog.find(1)).toBeDefined()

  describe ".pauseUpdates() and .resumeUpdates()", ->
    it "defers all update operations while paused, and resumes them when the last pause call is matched with a resume call", ->
      Monarch.Repository.pauseUpdates(); # first pause

      Monarch.Repository.update(Blog: { 1: { title: "Alpha" }})

      Monarch.Repository.pauseUpdates(); # second pause

      Monarch.Repository.update([
        ['create', 'Blog',  id: 2, title: "Bravo"],
        ['create', 'BlogPost',  id: 1, title: "Alpha", blogId: 1]
      ])

      Monarch.Repository.update(['create', 'Blog',  id: 3, title: "Charlie"])

      Monarch.Repository.resumeUpdates(); # first resume

      expect(Blog.size()).toBe(0)
      expect(BlogPost.size()).toBe(0)

      Monarch.Repository.resumeUpdates(); # final resume, updates are processed

      expect(Blog.size()).toBe(3)
      expect(BlogPost.size()).toBe(1)

      # updates no longer paused
      Monarch.Repository.update(['create', 'Blog',  id: 4, title: "Delta"])

      expect(Blog.size()).toBe(4)

  describe "#clear", ->
    it "removes all records from all tables without firing callbacks", ->
      blog1 = Blog.created(id: 1)
      Blog.created(id: 2)
      BlogPost.created(id: 1)
      BlogPost.created(id: 2)

      expect(Blog.size()).toBe(2)
      expect(BlogPost.size()).toBe(2)

      destroyCallback = jasmine.createSpy("destroyCallback")
      blog1.onDestroy(destroyCallback)

      Monarch.Repository.clear()

      expect(Blog.size()).toBe(0)
      expect(BlogPost.size()).toBe(0)
      expect(destroyCallback).not.toHaveBeenCalled()

    it "cancels all subscriptions", ->
      insertCallback = jasmine.createSpy("insertCallback")
      updateCallback = jasmine.createSpy("updateCallback")
      removeCallback = jasmine.createSpy("removeCallback")

      Blog.onInsert(insertCallback)
      Blog.onUpdate(updateCallback)
      Blog.onRemove(removeCallback)

      Monarch.Repository.clear()

      blog = Blog.created(id: 1)
      blog.updated(title: "A")
      blog.destroyed()

      expect(insertCallback).not.toHaveBeenCalled()
      expect(updateCallback).not.toHaveBeenCalled()
      expect(removeCallback).not.toHaveBeenCalled()

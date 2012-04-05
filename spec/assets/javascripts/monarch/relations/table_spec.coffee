describe "Monarch.Relations.Table", ->
  BlogPost = null

  beforeEach ->
    class BlogPost extends Monarch.Record
      @inherited(this)

  describe "events", ->
    [subscriptions, insertCallback, updateCallback, removeCallback] = []

    beforeEach ->
      BlogPost.columns
        blogId: 'integer'
        title: 'string'
        body: 'string'

      BlogPost.defaultOrderBy('blogId')

      insertCallback = jasmine.createSpy('insertCallback')
      updateCallback = jasmine.createSpy('updateCallback')
      removeCallback = jasmine.createSpy('removeCallback')

      subscriptions = new Monarch.Util.SubscriptionBundle()
      subscriptions.add(BlogPost.onInsert(insertCallback))
      subscriptions.add(BlogPost.onUpdate(updateCallback))
      subscriptions.add(BlogPost.onRemove(removeCallback))

    it "triggers events when one of its records is created, updated, or destroyed", ->
      BlogPost.created(id: 1, blogId: 1, title: "Title", body: "Body")
      expect(insertCallback).toHaveBeenCalled()
      expect(updateCallback).not.toHaveBeenCalled()
      post = insertCallback.arg(0)
      expect(insertCallback.arg(1)).toBe(0)

      BlogPost.created(id: 1, blogId: 2, title: "Title 2", body: "Body 2")
      expect(insertCallback).toHaveBeenCalled()
      expect(insertCallback.arg(1)).toBe(1)

      post.updated(blogId: 3, title: "Title Prime")
      expect(updateCallback).toHaveBeenCalled()
      expect(updateCallback.arg(0)).toBe(post)
      expect(updateCallback.arg(1)).toEqual
        blogId:
          newValue: 3
          oldValue: 1
          column: BlogPost.getColumn('blogId')
        title:
          newValue: "Title Prime"
          oldValue: "Title"
          column: BlogPost.getColumn('title')

      expect(updateCallback.arg(2)).toBe(1)
      expect(updateCallback.arg(3)).toBe(0)

      post.destroyed()
      expect(removeCallback).toHaveBeenCalled()
      expect(removeCallback.arg(0)).toBe(post)
      expect(removeCallback.arg(1)).toBe(1)

    it "always remains active, even if there are no subscriptions", ->
      expect(BlogPost.hasSubscriptions()).toBeTruthy()
      subscriptions.destroy()
      expect(BlogPost.hasSubscriptions()).toBeFalsy()
      expect(BlogPost.table.isActive).toBeTruthy()

  describe ".getColumn(name)", ->
    it "returns columns based on their bare or correctly-qualified names", ->
      BlogPost.columns
        blogId: 'integer'
        title: 'string'
        body: 'string'

      expect(BlogPost.getColumn('id').qualifiedName).toBe('BlogPost.id')
      expect(BlogPost.getColumn('title').qualifiedName).toBe('BlogPost.title')
      expect(BlogPost.getColumn('Blog.id')).toBeUndefined()
      expect(BlogPost.getColumn('BlogPost.junk')).toBeUndefined()
      expect(BlogPost.getColumn('BlogPost.id').qualifiedName).toBe('BlogPost.id')
      expect(BlogPost.getColumn('BlogPost.title').qualifiedName).toBe('BlogPost.title')

  describe ".defaultOrderBy", ->
    it "sorts records by the given specifications", ->
      BlogPost.columns
        blogId: 'integer',
        title: 'string'
      BlogPost.defaultOrderBy('blogId asc', 'title desc')

      # created in a random order to ensure correct order is not accidental
      post5 = BlogPost.created(id: 5, blogId: 3, title: "A")
      post1 = BlogPost.created(id: 1, blogId: 3, title: "A")
      post2 = BlogPost.created(id: 2, blogId: 2, title: "A")
      post4 = BlogPost.created(id: 4, blogId: 1, title: "B")
      post3 = BlogPost.created(id: 3, blogId: 1, title: "A")

      expect(BlogPost.at(0)).toBe(post4)
      expect(BlogPost.at(1)).toBe(post3)
      expect(BlogPost.at(2)).toBe(post2)
      expect(BlogPost.at(3)).toBe(post1)
      expect(BlogPost.at(4)).toBe(post5)

      # position is updated when order-critical fields change
      post5.updated(blogId: 1)
      expect(BlogPost.indexOf(post5)).toBe(2)

  describe ".find(idOrPredicate)", ->
    beforeEach ->
      BlogPost.columns(title: "string")

    describe "when passed an integer", ->
      it "returns a record with that id or null if none is found", ->
        blog = BlogPost.created(id: 2)
        expect(BlogPost.find(2)).toBe(blog)
        expect(BlogPost.find(99)).toBeUndefined()

    describe "when passed a hash", ->
      it "returns a record matching that predicate", ->
        blog = BlogPost.created(id: 2, title: "Title")
        expect(BlogPost.find(id: 2, title: "Title")).toBe(blog)
        expect(BlogPost.find(id: 2, title: "Boog")).toBeUndefined()

  describe ".findOrFetch(id)", ->
    findOrFetchSpy = []

    beforeEach ->
      findOrFetchSpy = jasmine.createSpy("findOrFetch")
      BlogPost.columns(title: "string")

    describe "when a record with the given id already exists in the repository", ->
      it "immediately triggers success on the promise with the record", ->
        blog = BlogPost.created( id: 2, title: "Major Rip-offs" )
        BlogPost.table.findOrFetch(2).onSuccess(findOrFetchSpy)
        expect(findOrFetchSpy).toHaveBeenCalledWith(blog)

    describe "when no record with the given id exists in the repository", ->
      it "fetches the record, returning the fetch promise", ->
        BlogPost.table.findOrFetch(2).onSuccess(findOrFetchSpy)
        expect($.ajax).toHaveBeenCalled()
        expect(lastAjaxRequest.type).toBe("get")

        record = BlogPost.created( id: 2 )
        lastAjaxRequest.success()
        expect(findOrFetchSpy).toHaveBeenCalledWith(record)

  it "has a .wireRepresentation()", ->
    expect(BlogPost.table.wireRepresentation()).toEqual
      type: 'table',
      name: 'blog_posts'

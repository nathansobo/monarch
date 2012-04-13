describe "Monarch.Relations.Projection", ->
  [User, Blog, BlogPost] = []

  beforeEach ->
    class User extends Monarch.Record
      @extended(this)
      @columns(premium: 'boolean')

    class Blog extends Monarch.Record
      @extended(this)
      @columns
        userId: 'integer',
        title: 'string'
      @defaultOrderBy('title')

    class BlogPost extends Monarch.Record
      @extended(this)
      @columns
        blogId: 'integer',
        title: 'string'
      @defaultOrderBy('title')

  describe ".all()", ->
    it "extracts records corresponding to the projected table from the underlying composite tuples", ->
      User.created(id: 1, premium: true)
      User.created(id: 2, premium: false)
      Blog.created(id: 1, userId: 1, title: "Alpha")
      Blog.created(id: 2, userId: 1, title: "Bravo")
      Blog.created(id: 3, userId: 2, title: "Charlie")
      post1 = BlogPost.created(id: 1, blogId: 1, title: "Alpha")
      post2 = BlogPost.created(id: 2, blogId: 1, title: "Bravo")
      post3 = BlogPost.created(id: 3, blogId: 2, title: "Charlie")
      BlogPost.created(id: 4, blogId: 3, title: "Delta")

      records = User.where(premium: true).join(Blog).joinThrough(BlogPost).all()
      expect(records).toEqual([post1, post2, post3])

    it "only includes distinct records", ->
      blog1 = Blog.created(id: 1)
      blog2 = Blog.created(id: 2)
      BlogPost.created(blogId: 1)
      BlogPost.created(blogId: 1)
      BlogPost.created(blogId: 2)

      expect(Blog.join(BlogPost).project(Blog).all()).toEqual([blog1, blog2])

  describe "events", ->
    [projection, insertCallback, updateCallback, removeCallback, subscriptions] = []

    beforeEach ->
      projection = Blog.where(userId: 1).join(BlogPost).project(Blog)
      subscriptions = new Monarch.Util.SubscriptionBundle()
      insertCallback = jasmine.createSpy('insertCallback')
      updateCallback = jasmine.createSpy('updateCallback')
      removeCallback = jasmine.createSpy('removeCallback')
      subscriptions.add(projection.onInsert(insertCallback))
      subscriptions.add(projection.onUpdate(updateCallback))
      subscriptions.add(projection.onRemove(removeCallback))

    describe "insert", ->
      it "triggers insert events when composites are inserted into the operand, but only if the record is not already a member of the relation", ->
        blog = Blog.created(id: 1, title: "Alpha", userId: 1)
        BlogPost.created(id: 1, blogId: 1, title: "Alpha")

        expect(insertCallback).toHaveBeenCalled()
        expect(insertCallback.arg(0)).toBe(blog)
        expect(insertCallback.arg(1)).toBe(0)
        insertCallback.reset()

        BlogPost.created(id: 2, blogId: 1, title: "Bravo")
        expect(insertCallback).not.toHaveBeenCalled()

    describe "update", ->
      it "triggers update events if a record in the projection is updated", ->
        blog1 = Blog.created(id: 1, title: "Alpha", userId: 1)
        blog2 = Blog.created(id: 2, title: "Bravo", userId: 1)
        post1 = BlogPost.created(id: 1, blogId: 1, title: "Alpha")
        post2 = BlogPost.created(id: 2, blogId: 2, title: "Bravo")
        post3 = BlogPost.created(id: 3, blogId: 1, title: "Charlie")

        post1.updated(title: "Echo")
        expect(updateCallback).not.toHaveBeenCalled()

        blog1.updated(title: "Zulu")
        expect(updateCallback.callCount).toBe(1)
        expect(updateCallback.arg(0)).toBe(blog1)
        expect(updateCallback.arg(1)).toEqual
          title:
            oldValue: "Alpha"
            newValue: "Zulu"
            column: Blog.getColumn('title')
        expect(updateCallback.arg(2)).toBe(1)
        expect(updateCallback.arg(3)).toBe(0)

    describe "remove", ->
      it "triggers remove events when the last composite containing a projected record is removed from the operand", ->
        blog = Blog.created(id: 1, title: "Alpha", userId: 1)
        post1 = BlogPost.created(id: 1, blogId: 1, title: "Alpha")
        post2 = BlogPost.created(id: 2, blogId: 1, title: "Bravo")

        post1.destroyed()
        expect(removeCallback).not.toHaveBeenCalled()

        post2.destroyed()
        expect(removeCallback).toHaveBeenCalled()
        expect(removeCallback.arg(0)).toBe(blog)
        expect(removeCallback.arg(1)).toBe(0)

  describe ".isEqual(other)", ->
    it "determines structural equality", ->
      projection1 = Blog.where(userId: 1).joinThrough(BlogPost)
      projection2 = Blog.where(userId: 1).joinThrough(BlogPost)
      expect(projection1).toEqual(projection2)

  it "has a .wireRepresentation()", ->
    expect(Blog.where(userId: 1).joinThrough(BlogPost).wireRepresentation()).toEqual
      type: 'table_projection'
      operand: Blog.where(userId: 1).join(BlogPost).wireRepresentation()
      projected_table: 'blog_posts'

  describe ".activate()", ->
    it "properly increments the recordCounts hash and does not hydrate the memoized contents with duplicate records", ->
      blog1 = Blog.created(id: 1)
      blog2 = Blog.created(id: 2)
      BlogPost.created(blogId: 1)
      BlogPost.created(blogId: 1)
      BlogPost.created(blogId: 2)

      projection = Blog.join(BlogPost).project(Blog)
      projection.activate()

      expect(projection.all()).toEqual([blog1, blog2])
      expect(projection.recordCounts[blog1.id()]).toBe(2)
      expect(projection.recordCounts[blog2.id()]).toBe(1)

  describe ".getColumn(name)", ->
    it "only returns columns from the projected table", ->
      projection = User.table.joinThrough(Blog)
      expect(projection.getColumn('title')).toEqual(Blog.getColumn('title'))
      expect(projection.getColumn('premium')).toBeUndefined()

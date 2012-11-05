describe "Monarch.Relations.InnerJoin", ->
  [Blog, BlogPost] = []

  beforeEach ->
    class Blog extends Monarch.Record
      @extended(this)
      @columns
        userId: 'integer'
        title: 'string'
      @defaultOrderBy('title')

    class BlogPost extends Monarch.Record
      @extended(this)
      @columns
        blogId: 'integer',
        title: 'string'
      @defaultOrderBy('title')

  describe "#initialize(left, right, predicate=null)", ->
    it "infers the predicate if one is not provided", ->
      inferred = Blog.where(userId: 1).join(BlogPost)
      explicit = Blog.where(userId: 1).join(BlogPost, blogId: 'Blog.id')
      expect(inferred).toEqual(explicit)

  describe "#all()", ->
    it "returns composite tuples from the cartesian product that match the predicate", ->
      blog1 = Blog.created(id: 1, userId: 1, title: "Alpha")
      blog2 = Blog.created(id: 2, userId: 2, title: "Bravo")
      blog3 = Blog.created(id: 3, userId: 1, title: "Charlie")
      post1 = BlogPost.created(id: 1, blogId: 1, title: "Alpha Post 1")
      post2 = BlogPost.created(id: 2, blogId: 1, title: "Alpha Post 2")
      post3 = BlogPost.created(id: 3, blogId: 2, title: "Bravo Post 1")
      post4 = BlogPost.created(id: 4, blogId: 3, title: "Charlie Post 1")

      tuples = Blog.where(userId: 1).join(BlogPost).all()

      expect(tuples.length).toBe(3)
      expect(tuples[0].left).toBe(blog1)
      expect(tuples[0].right).toBe(post1)
      expect(tuples[1].left).toBe(blog1)
      expect(tuples[1].right).toBe(post2)
      expect(tuples[2].left).toBe(blog3)
      expect(tuples[2].right).toBe(post4)

  describe "events", ->
    [insertCallback, updateCallback, removeCallback, subscriptions] = []

    beforeEach ->
      insertCallback = jasmine.createSpy('insertCallback')
      updateCallback = jasmine.createSpy('updateCallback')
      removeCallback = jasmine.createSpy('removeCallback')

    subscribe = (join) ->
      if subscriptions
        subscriptions.destroy()
      else
        subscriptions = new Monarch.Util.SubscriptionBundle()

      subscriptions.add(join.onInsert(insertCallback))
      subscriptions.add(join.onUpdate(updateCallback))
      subscriptions.add(join.onRemove(removeCallback))
      join

    describe "insert events", ->
      it "triggers insert events when a tuple in either operand is inserted", ->
        # inserts into right
        subscribe(Blog.join(BlogPost))
        blog1 = Blog.created(id: 1, userId: 1, title: "Alpha")
        post1 = BlogPost.created(id: 1, blogId: 1, title: "Alpha Post 1")
        expect(insertCallback).toHaveBeenCalled()
        composite = insertCallback.arg(0)
        expect(composite.left).toBe(blog1)
        expect(composite.right).toBe(post1)
        expect(insertCallback.arg(1)).toBe(0)
        insertCallback.reset()

        # inserts into left
        post2 = BlogPost.created(id: 2, blogId: 2, title: "Bravo Post 1")
        expect(insertCallback).not.toHaveBeenCalled()
        blog2 = Blog.created(id: 2, userId: 1, title: "Bravo")
        expect(insertCallback).toHaveBeenCalled()
        composite = insertCallback.arg(0)
        expect(composite.left).toBe(blog2)
        expect(composite.right).toBe(post2)
        expect(insertCallback.arg(1)).toBe(1)
        insertCallback.reset()

        Blog.created(id: 3, userId: 1, title: "Charlie")
        expect(insertCallback).not.toHaveBeenCalled()

      it "triggers insert events when a tuple is updated in an operand in a way that causes it to be in the join when it wasn't previously", ->
        blog1 = Blog.created(id: 1, userId: 1, title: "Alpha")
        post1 = BlogPost.created(id: 1, blogId: 2, title: "Alpha Post 1")
        post2 = BlogPost.created(id: 2, blogId: 3, title: "Alpha Post 1")

        subscribe(Blog.join(BlogPost))

        post1.updated(blogId: 1)

        expect(insertCallback).toHaveBeenCalled()
        composite = insertCallback.arg(0)
        expect(composite.left).toBe(blog1)
        expect(composite.right).toBe(post1)
        expect(updateCallback).not.toHaveBeenCalled()
        insertCallback.reset()

        subscribe(BlogPost.join(Blog))

        post2.updated(blogId: 1)

        expect(insertCallback).toHaveBeenCalled()
        composite = insertCallback.arg(0)
        expect(composite.left).toBe(post2)
        expect(composite.right).toBe(blog1)
        expect(updateCallback).not.toHaveBeenCalled()
        insertCallback.reset()

    describe "update events", ->
      it "triggers update events when tuples in either operand are updated in a way that does not affect their membership in the join", ->
        # updates on the right
        blog1 = Blog.created(id: 1, userId: 1, title: "Alpha")
        blog2 = Blog.created(id: 2, userId: 1, title: "Bravo")
        blog3 = Blog.created(id: 3, userId: 2, title: "Charlie")
        blog4 = Blog.created(id: 4, userId: 1, title: "Delta"); # empty
        post1 = BlogPost.created(id: 1, blogId: 1, title: "Alpha")
        post2 = BlogPost.created(id: 2, blogId: 1, title: "Bravo")
        post3 = BlogPost.created(id: 3, blogId: 1, title: "Charlie")
        post4 = BlogPost.created(id: 4, blogId: 2, title: "Alpha")
        post5 = BlogPost.created(id: 5, blogId: 2, title: "Bravo")
        post6 = BlogPost.created(id: 6, blogId: 3, title: "Alpha")

        join = subscribe(Blog.where(userId: 1).join(BlogPost))
        expectedTuple = join.at(2)
        expect(expectedTuple.left).toBe(blog1)
        expect(expectedTuple.right).toBe(post3)

        post3.updated(title: "Alpha 1")

        expect(updateCallback).toHaveBeenCalled()
        expect(updateCallback.arg(0)).toBe(expectedTuple)
        expect(updateCallback.arg(1)).toEqual
          title:
            oldValue: "Charlie"
            newValue: "Alpha 1"
            column: BlogPost.getColumn('title')
        expect(updateCallback.arg(2)).toBe(1)
        expect(updateCallback.arg(3)).toBe(2)
        updateCallback.reset()

        post6.updated(title: "Alpha 1")
        expect(updateCallback).not.toHaveBeenCalled()

        # left operand
        blog2.updated(title: "0 Alpha")
        expectedChangeset =
          title:
            oldValue: "Bravo"
            newValue: "0 Alpha"
            column: Blog.getColumn('title')

        expect(updateCallback.callCount).toBe(2)
        tuple1 = updateCallback.argsForCall[0][0]
        expect(tuple1.left).toBe(blog2)
        expect(tuple1.right).toBe(post4)
        expect(updateCallback.argsForCall[0][1]).toEqual(expectedChangeset)
        expect(updateCallback.argsForCall[0][2]).toBe(0); # new index
        expect(updateCallback.argsForCall[0][3]).toBe(3); # old index

        tuple2 = updateCallback.argsForCall[1][0]
        expect(tuple2.left).toBe(blog2)
        expect(tuple2.right).toBe(post5)
        expect(updateCallback.argsForCall[1][1]).toEqual(expectedChangeset)
        expect(updateCallback.argsForCall[1][2]).toBe(1); # new index
        expect(updateCallback.argsForCall[1][3]).toBe(4); # old index

        updateCallback.reset()

        blog4.updated(title: "Echo")

        expect(updateCallback).not.toHaveBeenCalled()

    describe "remove events", ->
      [blog1, blog2, post1, post2, post3, post4] = []

      beforeEach ->
        blog1 = Blog.created(id: 1, userId: 1, title: "Alpha")
        blog2 = Blog.created(id: 2, userId: 1, title: "Alpha")
        post1 = BlogPost.created(id: 1, blogId: 1, title: "Alpha")
        post2 = BlogPost.created(id: 2, blogId: 1, title: "Bravo")
        post3 = BlogPost.created(id: 3, blogId: 1, title: "Bravo")
        post4 = BlogPost.created(id: 4, blogId: 3, title: "Charlie")

      it "triggers remove events if a tuple is removed from an operand", ->
        join = subscribe(Blog.join(BlogPost))
        expectedTuple = join.at(1)
        expect(expectedTuple.left).toBe(blog1)
        expect(expectedTuple.right).toBe(post2)

        # right operand
        post2.destroyed()
        expect(removeCallback).toHaveBeenCalled()
        expect(removeCallback.arg(0)).toBe(expectedTuple)
        expect(removeCallback.arg(1)).toBe(1)
        removeCallback.reset()

        post4.destroyed()
        expect(removeCallback).not.toHaveBeenCalled()

        # left operand
        expectedTuple1 = join.at(0)
        expectedTuple2 = join.at(1)
        expect(expectedTuple1.left).toBe(blog1)
        expect(expectedTuple1.right).toBe(post1)
        expect(expectedTuple2.left).toBe(blog1)
        expect(expectedTuple2.right).toBe(post3)

        blog1.destroyed()
        expect(removeCallback.callCount).toBe(2)
        expect(removeCallback.argsForCall[0][0]).toBe(expectedTuple1)
        expect(removeCallback.argsForCall[0][1]).toBe(0)
        expect(removeCallback.argsForCall[1][0]).toBe(expectedTuple2)
        expect(removeCallback.argsForCall[1][1]).toBe(0)
        removeCallback.reset()

        blog2.destroyed()
        expect(removeCallback).not.toHaveBeenCalled()

      it "triggers remove events if a tuple is updated to no longer match the predicate", ->
        # right operand
        join1 = subscribe(Blog.join(BlogPost))
        expectedTuple = join1.at(1)
        expect(expectedTuple.left).toBe(blog1)
        expect(expectedTuple.right).toBe(post2)

        post2.updated(blogId: 100)
        expect(removeCallback).toHaveBeenCalled()
        expect(removeCallback.arg(0)).toBe(expectedTuple)
        expect(removeCallback.arg(1)).toBe(1)
        removeCallback.reset()

        # left operand
        join2 = subscribe(BlogPost.join(Blog))
        expectedTuple = join2.at(1)
        expect(expectedTuple.left).toBe(post3)
        expect(expectedTuple.right).toBe(blog1)

        post3.updated(blogId: 100)
        expect(removeCallback).toHaveBeenCalled()
        expect(removeCallback.arg(0)).toBe(expectedTuple)
        expect(removeCallback.arg(1)).toBe(1)
        removeCallback.reset()

    describe "deactivation", ->
      it "removes subscriptions on the operands", ->
        expect(BlogPost.hasSubscriptions()).toBeFalsy()
        expect(Blog.hasSubscriptions()).toBeFalsy()

        subscribe(Blog.join(BlogPost))

        expect(BlogPost.hasSubscriptions()).toBeTruthy()
        expect(Blog.hasSubscriptions()).toBeTruthy()

        subscriptions.destroy()

        expect(BlogPost.hasSubscriptions()).toBeFalsy()
        expect(Blog.hasSubscriptions()).toBeFalsy()

  it "has a #wireRepresentation()", ->
    left = Blog.where(userId: 1)
    right = BlogPost.table

    expect(left.join(right).wireRepresentation()).toEqual
      type: 'InnerJoin'
      leftOperand: left.wireRepresentation()
      rightOperand: right.wireRepresentation()
      predicate:
        type: 'Equal',
        leftOperand:
          type: 'Column'
          table: 'blogs'
          name: 'id'
        rightOperand:
          type: 'Column'
          table: 'blog-posts'
          name: 'blog-id'

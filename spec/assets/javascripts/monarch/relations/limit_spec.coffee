describe "Monarch.Relations.Limit", ->
  BlogPost = null

  beforeEach ->
    class BlogPost extends Monarch.Record
      @extended(this)
      @columns title: "string"
      @defaultOrderBy('title')

  describe "#all()", ->
    it "returns up to 'count' records", ->
      post1 = BlogPost.created(id: 1, title: "Alpha")
      post2 = BlogPost.created(id: 2, title: "Bravo")
      post3 = BlogPost.created(id: 3, title: "Charlie")

      expect(BlogPost.limit(2).all()).toEqual([post1, post2])
      expect(BlogPost.limit(4).all()).toEqual([post1, post2, post3])

  describe "events", ->
    [subscriptions, insertCallback, updateCallback, removeCallback] = []

    beforeEach ->
      subscriptions = new Monarch.Util.SubscriptionBundle()
      insertCallback = jasmine.createSpy('insertCallback')
      updateCallback = jasmine.createSpy('updateCallback')
      removeCallback = jasmine.createSpy('removeCallback')

      relation = BlogPost.limit(2)
      subscriptions.add(relation.onInsert(insertCallback))
      subscriptions.add(relation.onUpdate(updateCallback))
      subscriptions.add(relation.onRemove(removeCallback))

    describe "insert events", ->
      it "triggers insert events if tuples are added to the operand at an index lower than the count", ->
        post1 = BlogPost.created(id: 1, title: "Alpha")
        expect(insertCallback).toHaveBeenCalled()
        expect(insertCallback.arg(0)).toBe(post1)
        expect(insertCallback.arg(1)).toBe(0)
        insertCallback.reset()

        post2 = BlogPost.created(id: 2, title: "Bravo")
        expect(insertCallback).toHaveBeenCalled()
        expect(insertCallback.arg(0)).toBe(post2)
        expect(insertCallback.arg(1)).toBe(1)
        insertCallback.reset()

        BlogPost.created(id: 3, title: "Charlie")
        expect(insertCallback).not.toHaveBeenCalled()

      it "triggers insert events if tuples are updated in the operand to have and index falling under the count", ->
        post1 = BlogPost.created(id: 1, title: "Alpha")
        post2 = BlogPost.created(id: 2, title: "Charlie")
        post3 = BlogPost.created(id: 3, title: "Echo")
        insertCallback.reset()

        post3.updated(title: "Bravo")
        expect(insertCallback).toHaveBeenCalled()
        expect(insertCallback.arg(0)).toBe(post3)
        expect(insertCallback.arg(1)).toBe(1)
        insertCallback.reset()

        post3.updated(title: "0 Alpha")
        expect(insertCallback).not.toHaveBeenCalled()

      it "triggers insert events if a removed tuple causes a new tuple to fall under the count", ->
        post1 = BlogPost.created(id: 1, title: "Alpha")
        post2 = BlogPost.created(id: 2, title: "Charlie")
        post3 = BlogPost.created(id: 3, title: "Echo")
        insertCallback.reset()

        post2.updated(title: "Zulu")
        expect(insertCallback).toHaveBeenCalled()
        expect(insertCallback.arg(0)).toBe(post3)
        expect(insertCallback.arg(1)).toBe(1)
        insertCallback.reset()

        post1.destroyed()
        expect(insertCallback).toHaveBeenCalled()
        expect(insertCallback.arg(0)).toBe(post2)
        expect(insertCallback.arg(1)).toBe(1)
        insertCallback.reset()

        post2.destroyed()
        expect(insertCallback).not.toHaveBeenCalled()

    describe "update events", ->
      it "triggers update events if a tuple in the operand with an index below the count is updated to keep its index below the count", ->
        post1 = BlogPost.created(id: 1, title: "Alpha")
        post2 = BlogPost.created(id: 2, title: "Charlie")
        post3 = BlogPost.created(id: 3, title: "Echo")
        insertCallback.reset()

        post1.updated(title: "Delta")
        expect(updateCallback).toHaveBeenCalled()
        expect(updateCallback.arg(0)).toBe(post1)
        expect(updateCallback.arg(1)).toEqual
          title:
            oldValue: "Alpha"
            newValue: "Delta"
            column: BlogPost.getColumn('title')
        expect(updateCallback.arg(2)).toBe(1)
        expect(updateCallback.arg(3)).toBe(0)
        updateCallback.reset()

        post3.updated(title: "Foxtrot")
        expect(updateCallback).not.toHaveBeenCalled()

        post2.updated(title: "Uniform")
        expect(updateCallback).not.toHaveBeenCalled()

        post2.updated(title: "Alpha")
        expect(updateCallback).not.toHaveBeenCalled()

    describe "remove events", ->
      [post1, post2, post3] = []
      beforeEach ->
        post1 = BlogPost.created(id: 1, title: "Alpha")
        post2 = BlogPost.created(id: 2, title: "Charlie")
        post3 = BlogPost.created(id: 3, title: "Echo")
        insertCallback.reset()

      it "triggers remove events when a tuple in the operand is removed with an index lower than count", ->
        post2.destroyed()
        expect(removeCallback).toHaveBeenCalled()
        expect(removeCallback.arg(0)).toBe(post2)
        expect(removeCallback.arg(1)).toBe(1)

      it "triggers remove events when a tuple with an index lower than the count is updated to have an index higher than the count", ->
        post1.updated(title: "Uniform")
        expect(removeCallback).toHaveBeenCalled()
        expect(removeCallback.arg(0)).toBe(post1)
        expect(removeCallback.arg(1)).toBe(0)

      it "triggers remove events when the insertion of a tuple causes the last tuple to fall off the end of the limit", ->
        # updates
        post3.updated(title: "Bravo")
        expect(removeCallback).toHaveBeenCalled()
        expect(removeCallback.arg(0)).toBe(post2)
        expect(removeCallback.arg(1)).toBe(1)
        removeCallback.reset()

        # inserts
        BlogPost.created(id: 4, title: "0 Alpha")
        expect(removeCallback).toHaveBeenCalled()
        expect(removeCallback.arg(0)).toBe(post3)
        expect(removeCallback.arg(1)).toBe(1)

    describe "the #limit(limitCount, offsetCount) method", ->
      it "builds limits / offsets", ->
        expect(BlogPost.limit(4, 10)).toEqual(BlogPost.offset(10).limit(4))

    it "has a #wireRepresentation()", ->
      expect(BlogPost.limit(5).wireRepresentation()).toEqual
        type: 'limit'
        operand: BlogPost.table.wireRepresentation()
        count: 5

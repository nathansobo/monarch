describe "Monarch.Relations.Union", ->
  BlogPost = null

  beforeEach ->
    class BlogPost extends Monarch.Record
      @extended(this)
      @columns
        blogId: 'integer'
        public: 'boolean'
        title: 'string'
      @defaultOrderBy('title')

  describe "#all", ->
    it "returns the union of the left and the right", ->
      post1 = BlogPost.created(id: 1, blogId: 1, public: true, title: "Alpha")
      post2 = BlogPost.created(id: 2, blogId: 1, public: false, title: "Bravo")
      post3 = BlogPost.created(id: 3, blogId: 1, public: true, title: "Delta")
      post4 = BlogPost.created(id: 4, blogId: 2, public: false, title: "Echo")
      post5 = BlogPost.created(id: 5, blogId: 2, public: true, title: "Foxtrot")
      post6 = BlogPost.created(id: 6, blogId: 2, public: false, title: "Golf")
      records = BlogPost.where(blogId: 1).union(BlogPost.where(public: true)).all()
      expect(records).toEqual([post1, post2, post3, post5])

  describe "events", ->
    [union, insertCallback, updateCallback, removeCallback, subscriptions] = []

    beforeEach ->
      union = BlogPost.where(blogId: 1).union(BlogPost.where(public: true))
      subscriptions = new Monarch.Util.SubscriptionBundle()
      insertCallback = jasmine.createSpy('insertCallback')
      updateCallback = jasmine.createSpy('updateCallback')
      removeCallback = jasmine.createSpy('removeCallback')

      subscriptions.add(union.onInsert(insertCallback))
      subscriptions.add(union.onUpdate(updateCallback))
      subscriptions.add(union.onRemove(removeCallback))

    describe "insert events", ->
      it "triggers insert events when records are inserted into one operand that aren't in the other", ->
        post1 = BlogPost.created(id: 1, public: true, title: "Alpha", blogId: 2)
        expect(insertCallback).toHaveBeenCalled()
        expect(insertCallback.arg(0)).toBe(post1)
        expect(insertCallback.arg(1)).toBe(0)
        insertCallback.reset()

        post2 = BlogPost.created(id: 2, public: false, title: "Bravo", blogId: 1)
        expect(insertCallback).toHaveBeenCalled()
        expect(insertCallback.arg(0)).toBe(post2)
        expect(insertCallback.arg(1)).toBe(1)
        insertCallback.reset()


        post1.updated(blogId: 1, title: "Uniform")
        expect(insertCallback).not.toHaveBeenCalled()
        expect(union.at(0)).toBe(post2)
        expect(union.at(1)).toBe(post1)

        post2.updated(public: true, title: "Zulu")
        expect(insertCallback).not.toHaveBeenCalled()
        expect(union.at(0)).toBe(post1)
        expect(union.at(1)).toBe(post2)

    describe "update events", ->
      it "triggers a single update event when records in the operands are updated, even the record is present in both", ->
        post1 = BlogPost.created(id: 1, public: false, title: "Alpha", blogId: 1)
        post2 = BlogPost.created(id: 2, public: true, title: "Echo", blogId: 1)
        post3 = BlogPost.created(id: 3, public: true, title: "Golf", blogId: 2)

        # left
        post1.updated(title: "Foxtrot")
        expect(updateCallback.callCount).toBe(1)
        expect(updateCallback.arg(0)).toBe(post1)
        expect(updateCallback.arg(1)).toEqual
          title:
            oldValue: "Alpha"
            newValue: "Foxtrot"
            column: BlogPost.getColumn('title')
        expect(updateCallback.arg(2)).toBe(1)
        expect(updateCallback.arg(3)).toBe(0)
        updateCallback.reset()

        # right
        post3.updated(title: "Alpha")
        expect(updateCallback.callCount).toBe(1)
        expect(updateCallback.arg(0)).toBe(post3)
        expect(updateCallback.arg(1)).toEqual
          title:
            oldValue: "Golf",
            newValue: "Alpha",
            column: BlogPost.getColumn('title')
        expect(updateCallback.arg(2)).toBe(0)
        expect(updateCallback.arg(3)).toBe(2)
        updateCallback.reset()

        # both
        post2.updated(title: "Golf")
        expect(updateCallback.callCount).toBe(1)
        expect(updateCallback.arg(0)).toBe(post2)
        expect(updateCallback.arg(1)).toEqual
          title:
            oldValue: "Echo"
            newValue: "Golf"
            column: BlogPost.getColumn('title')
        expect(updateCallback.arg(2)).toBe(2)
        expect(updateCallback.arg(3)).toBe(1)

    describe "remove events", ->
      it "triggers a remove event when a record is removed from an operand and it isn't present in the other", ->
        post1 = BlogPost.created(id: 1, public: true, title: "Alpha", blogId: 1)
        post2 = BlogPost.created(id: 2, public: true, title: "Bravo", blogId: 1)
        post3 = BlogPost.created(id: 3, public: true, title: "Charlie", blogId: 1)

        # remove left then right
        post1.updated(blogId: 100, title: "Zulu")
        expect(removeCallback).not.toHaveBeenCalled()
        post1.updated(public: false)
        expect(removeCallback.callCount).toBe(1)
        expect(removeCallback.arg(0)).toBe(post1)
        expect(removeCallback.arg(1)).toBe(2)
        removeCallback.reset()

        # remove from right then left
        post2.updated(public: false, title: "Zulu")
        expect(removeCallback).not.toHaveBeenCalled()
        post2.updated(blogId: 100)
        expect(removeCallback.callCount).toBe(1)
        expect(removeCallback.arg(0)).toBe(post2)
        expect(removeCallback.arg(1)).toBe(1)
        removeCallback.reset()

        # remove from both simultaneously
        post3.destroyed()
        expect(removeCallback.callCount).toBe(1)
        expect(removeCallback.arg(0)).toBe(post3)
        expect(removeCallback.arg(1)).toBe(0)

  describe "#isEqual(other)", ->
    it "determines structural equality", ->
      union1 = BlogPost.where(blogId: 1).union(BlogPost.where(blogId: 2))
      union2 = BlogPost.where(blogId: 1).union(BlogPost.where(blogId: 2))
      union3 = BlogPost.where(blogId: 1).union(BlogPost.where(blogId: 3))

      expect(union1).toEqual(union2)
      expect(union1).not.toEqual(union3)

  it "has a #wireRepresentation()", ->
    left = BlogPost.where(blogId: 1)
    right = BlogPost.where(blogId: 2)

    expect(left.union(right).wireRepresentation()).toEqual
      type: 'union'
      left_operand: left.wireRepresentation()
      right_operand: right.wireRepresentation()

describe "Monarch.Relations.Selection", ->
  [BlogPost, post1, post2, post3, post4] = []

  beforeEach ->
    class BlogPost extends Monarch.Record
      @extended(this)
      @columns
        blogId: 'integer',
        title: 'string'
      @defaultOrderBy('title')

    post1 = BlogPost.created(id: 1, blogId: 1, title: "Beta")
    post2 = BlogPost.created(id: 2, blogId: 1, title: "Charlie")
    post3 = BlogPost.created(id: 3, blogId: 2, title: "Charlie")
    post4 = BlogPost.created(id: 4, blogId: 3, title: "Delta")

  describe ".all()", ->
    it "returns tuples that match the predicate", ->
      expect(BlogPost.where(blogId: 1).all()).toEqual([post1, post2])
      expect(BlogPost.where(title: "Charlie").all()).toEqual([post2, post3])
      expect(BlogPost.where(blogId: 2, title: "Charlie").all()).toEqual([post3])
      expect(BlogPost.where(BlogPost.getColumn('blogId').eq(2).and(title: "Charlie")).all()).toEqual([post3])

  describe ".create(attributes)", ->
    it "calls #create on the operand after extending the attributes with to satisfy the predicate", ->
      spyOn(BlogPost.table, 'create')
      BlogPost.where( blogId: 2, title: "Charlie" ).create( foo: "bar" )
      expect(BlogPost.table.create).toHaveBeenCalledWith( blogId: 2, title: "Charlie", foo: "bar" )

  describe ".created(attributes)", ->
    it "calls #created on the operand after extending the attributes with to satisfy the predicate", ->
      spyOn(BlogPost.table, 'created')
      BlogPost.where( blogId: 2, title: "Charlie" ).created( foo: "bar" )
      expect(BlogPost.table.created).toHaveBeenCalledWith( blogId: 2, title: "Charlie", foo: "bar" )

  describe "events", ->
    [selection, insertCallback, updateCallback, removeCallback, subscriptions] = []

    beforeEach ->
      selection = BlogPost.where(blogId: 1)
      subscriptions = new Monarch.Util.SubscriptionBundle()
      insertCallback = jasmine.createSpy('insertCallback')
      updateCallback = jasmine.createSpy('updateCallback')
      removeCallback = jasmine.createSpy('removeCallback')

      subscriptions.add(selection.onInsert(insertCallback))
      subscriptions.add(selection.onUpdate(updateCallback))
      subscriptions.add(selection.onRemove(removeCallback))

    describe "insert events", ->
      it "triggers them if an event on the underlying relation leads to insertion", ->
        newPost = BlogPost.created(id: 100, blogId: 1)
        expect(insertCallback).toHaveBeenCalled()
        expect(insertCallback.arg(0)).toBe(newPost)
        expect(insertCallback.arg(1)).toBe(2)
        expect(updateCallback).not.toHaveBeenCalled()
        insertCallback.reset()

        post3.updated(blogId: 1)
        expect(insertCallback).toHaveBeenCalled()
        expect(insertCallback.arg(0)).toBe(post3)
        expect(insertCallback.arg(1)).toBe(2)
        expect(updateCallback).not.toHaveBeenCalled()

    describe "update events", ->
      it "triggers them if a tuple in the selection is updated", ->
        post2.updated(title: "Alpha")
        expect(updateCallback).toHaveBeenCalled()
        expect(updateCallback.arg(0)).toBe(post2)
        expect(updateCallback.arg(1)).toEqual
          title:
            oldValue: "Charlie"
            newValue: "Alpha"
            column: BlogPost.getColumn('title')
        expect(updateCallback.arg(2)).toBe(0)
        expect(updateCallback.arg(3)).toBe(1)
        expect(insertCallback).not.toHaveBeenCalled()
        updateCallback.reset()

        post3.updated(title: "Omega")
        expect(updateCallback).not.toHaveBeenCalled()
        expect(removeCallback).not.toHaveBeenCalled()

    describe "remove events", ->
      it "triggers them if a tuple in the selection is removed", ->
        post2.updated(blogId: 100, title: "X-Ray")
        expect(removeCallback).toHaveBeenCalled()
        expect(removeCallback.arg(0)).toBe(post2)
        expect(removeCallback.arg(1)).toBe(1)
        removeCallback.reset()

        post1.destroyed()
        expect(removeCallback).toHaveBeenCalled()
        expect(removeCallback.arg(0)).toBe(post1)
        expect(removeCallback.arg(1)).toBe(0)

      it "triggers them correctly even if the underlying cause of the removal was an order-disrupting update", ->
        selection = BlogPost.where(title: "Charlie").where(blogId: 1)
        expect(selection.contains(post2)).toBeTruthy()
        selection.onRemove(removeCallback)

        post2.updated(title: "X-Ray")
        expect(removeCallback).toHaveBeenCalled()
        expect(removeCallback.arg(0)).toBe(post2)
        expect(removeCallback.arg(1)).toBe(0)

    describe "deactivation", ->
      it "destroys subscriptions on the operand when the last of its subscriptions is removed", ->
        expect(selection.isActive).toBeTruthy()
        expect(BlogPost.hasSubscriptions()).toBeTruthy()
        subscriptions.destroy()
        expect(selection.isActive).toBeFalsy()
        expect(BlogPost.hasSubscriptions()).toBeFalsy()

  it "supports inequality predicates", ->
    expect(BlogPost.where('blogId <': 3).all()).toEqual([post1, post2, post3])
    expect(BlogPost.where('blogId <=': 2).all()).toEqual([post1, post2, post3])
    expect(BlogPost.where('blogId >': 1).all()).toEqual([post3, post4])
    expect(BlogPost.where('blogId >=': 2).all()).toEqual([post3, post4])

  describe ".contains(tuple)", ->
    it "works even when the relation is not active", ->
      expect(BlogPost.where(blogId: 1).contains(post2)).toBeTruthy()

  describe ".indexOf(tuple)", ->
    it "works even when the relation is not active", ->
      expect(BlogPost.where(blogId: 1).indexOf(post2)).toBe(1)

  describe ".isEqual(other)", ->
    it "returns true if the other selection is structurally equivalent", ->
      expect(BlogPost.where(blogId: 1).isEqual(BlogPost.where(blogId: 1))).toBeTruthy()
      expect(BlogPost.where(blogId: 1).isEqual(BlogPost.where(blogId: 2))).toBeFalsy()
      expect(BlogPost.where(blogId: 1).isEqual(null)).toBeFalsy()

  describe ".wireRepresentation()", ->
    it "works for comparison with numbers", ->
      expect(BlogPost.where(blogId: 2).wireRepresentation()).toEqual
        type: 'Selection'
        predicate:
          type: 'Equal'
          leftOperand:
            type: 'Column'
            table: 'BlogPost'
            name: 'blogId'
          rightOperand:
            type: 'Scalar'
            value: 2
        operand: BlogPost.table.wireRepresentation()

    it "works for comparison with undefined", ->
      expect(BlogPost.where(blogId: null).wireRepresentation()).toEqual
        type: 'Selection'
        predicate:
          type: 'Equal'
          leftOperand:
            type: 'Column'
            table: 'BlogPost'
            name: 'blogId'
          rightOperand:
            type: 'Scalar'
            value: null
        operand: BlogPost.table.wireRepresentation()

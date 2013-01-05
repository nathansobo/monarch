describe "Monarch.Remote.FakeServer", ->
  [Blog, fakeServer] = []

  beforeEach ->
    class Blog extends Monarch.Record
      @extended(this)
      @columns
        title: 'string',
        createdAt: 'datetime'

    Monarch.useFakeServer()
    fakeServer = Monarch.Remote.Server

  afterEach ->
    Monarch.restoreOriginalServer()

  describe "creation with the fake server installed", ->
    it "stores a simulated create request, which can be explicitly completed", ->
      promise = Blog.create(title: "Alpha", createdAt: new Date(12345))
      expect(jQuery.ajax).not.toHaveBeenCalled()

      expect(fakeServer.creates.length).toBe(1)
      createCommand = fakeServer.lastCreate()
      record = createCommand.record
      expect(createCommand).toBe(fakeServer.creates[0])
      expect(record instanceof Blog).toBeTruthy()
      expect(createCommand.fieldValues).toEqual(title: "Alpha", createdAt: 12345)

      successCallback = jasmine.createSpy("successCallback")
      promise.onSuccess(successCallback)

      createCommand.succeed()
      expect(successCallback).toHaveBeenCalledWith(record)
      expect(record.id()).toBe(1)
      expect(Blog.find(1)).toBe(record)

      # auto-selects the next available id
      Blog.created(id: 5, title: "Bravo")
      Blog.create(title: "Charlie", createdAt: new Date(12345))
      createCommand2 = fakeServer.lastCreate()
      createCommand2.succeed()
      expect(createCommand2.record.id()).toBe(6)

    it "allows simulated response values from the server to be specified for succeed", ->
      Blog.create(title: "Alpha", createdAt: new Date(12345))
      createCommand = fakeServer.lastCreate()

      createCommand.succeed
        id: 22,
        title: "Zulu",
        createdAt: 98765

      record = createCommand.record
      expect(record.id()).toBe(22)
      expect(record.title()).toBe("Zulu")
      expect(record.createdAt().getTime()).toBe(98765)

    it "removes the command from the 'creates' array when the create succeeds", ->
      Blog.create(title: "Alpha", createdAt: new Date(12345))
      fakeServer.lastCreate().succeed()
      expect(fakeServer.creates.length).toBe(0)

      Blog.create(title: "Bravo")
      create1 = fakeServer.lastCreate()
      Blog.create(title: "Charlie")
      create2 = fakeServer.lastCreate()

      create1.succeed()

      expect(fakeServer.creates.length).toBe(1)
      expect(fakeServer.lastCreate()).toBe(create2)

  describe "updates with the fake server installed", ->
    it "stores a simulated update request, which can be explicitly completed", ->
      blog = Blog.created(id: 1, title: "Alpha", createdAt: new Date(12345))
      promise = blog.update(title: "Bravo", createdAt: new Date(54321))
      expect(jQuery.ajax).not.toHaveBeenCalled()
      expect(blog.getRemoteField('title').getValue()).toBe("Alpha")
      expect(blog.getRemoteField('createdAt').getValue().getTime()).toBe(12345)

      expect(fakeServer.updates.length).toBe(1)
      updateCommand = fakeServer.lastUpdate()
      expect(updateCommand).toBe(fakeServer.updates[0])
      expect(updateCommand.record).toBe(blog)
      expect(updateCommand.fieldValues).toEqual(title: "Bravo", createdAt: 54321)

      successCallback = jasmine.createSpy("successCallback")
      promise.onSuccess(successCallback)

      updateCommand.succeed()
      expect(successCallback).toHaveBeenCalled()
      expect(successCallback.arg(0)).toBe(blog)
      expect(successCallback.arg(1)).toEqual {}

      expect(blog.title()).toBe("Bravo")
      expect(blog.createdAt().getTime()).toBe(54321)

    it "allows simulated response values from the server to be specified for succeed", ->
      blog = Blog.created(id: 1, title: "Alpha", createdAt: new Date(12345))
      blog.update(title: "Bravo", createdAt: new Date(54321))

      Blog.create(title: "Alpha", createdAt: new Date(12345))
      updateCommand = fakeServer.lastUpdate()

      updateCommand.succeed
        title: "Zulu",
        createdAt: 98765

      expect(blog.title()).toBe("Zulu")
      expect(blog.createdAt().getTime()).toBe(98765)

    it "removes the command from the 'creates' array when the create succeeds", ->
      blog = Blog.created(id: 1, title: "Alpha", createdAt: new Date(12345))
      blog.update(title: "Bravo", createdAt: new Date(54321))
      fakeServer.lastUpdate().succeed()
      expect(fakeServer.updates.length).toBe(0)

      blog.update(title: "Bravo")
      update1 = fakeServer.lastUpdate()
      blog.update(title: "Charlie")
      update2 = fakeServer.lastUpdate()

      update1.succeed()

      expect(fakeServer.updates.length).toBe(1)
      expect(fakeServer.lastUpdate()).toBe(update2)

  describe "destroys with the fake server installed", ->
    it "stores a simulated destroy request, which can be explicitly completed", ->
      blog = Blog.created(id: 1, title: "Alpha", createdAt: new Date(12345))
      promise = blog.destroy(title: "Bravo", createdAt: new Date(54321))
      expect(jQuery.ajax).not.toHaveBeenCalled()
      expect(Blog.find(1)).toBe(blog)

      expect(fakeServer.destroys.length).toBe(1)
      destroyCommand = fakeServer.lastDestroy()
      expect(destroyCommand).toBe(fakeServer.destroys[0])
      expect(destroyCommand.record).toBe(blog)

      successCallback = jasmine.createSpy("successCallback")
      promise.onSuccess(successCallback)

      destroyCommand.succeed()
      expect(successCallback).toHaveBeenCalled()
      expect(successCallback.arg(0)).toBe(blog)

      expect(Blog.find(1)).toBeUndefined()

    it "removes the command from the 'destroys' array when the destroy succeeds", ->
      blog = Blog.created(id: 1, title: "Alpha", createdAt: new Date(12345))
      blog.destroy()
      fakeServer.lastDestroy().succeed()
      expect(fakeServer.destroys.length).toBe(0)

      blog2 = Blog.created(id: 2, title: "Bravo", createdAt: new Date(12345))
      blog3 = Blog.created(id: 3, title: "Charlie", createdAt: new Date(12345))

      blog2.destroy()
      destroy1 = fakeServer.lastDestroy()
      blog3.destroy()
      destroy2 = fakeServer.lastDestroy()

      destroy1.succeed()

      expect(fakeServer.destroys.length).toBe(1)
      expect(fakeServer.lastDestroy()).toBe(destroy2)

  describe "when the 'auto' property is true on the fake server", ->
    it "automatically completes all requests", ->
      fakeServer.auto = true

      Blog.create()
      expect(Blog.size()).toBe(1)

      blog = Blog.first()

      blog.update(title: "Foo")
      expect(blog.title()).toEqual("Foo")

      blog.destroy()
      expect(Blog.find(blog.id())).toBeUndefined()

      fetchSuccessCallback = jasmine.createSpy("fetchSuccessCallback")
      Blog.fetch().onSuccess(fetchSuccessCallback)
      expect(fetchSuccessCallback).toHaveBeenCalled()

  describe "fetches with the fake server installed", ->
    [rel1, rel2] = []

    beforeEach ->
      rel1 = Blog.where( 'createdAt >': new Date(12345) )
      rel2 = Blog.where( 'title': "Charlie" )

    it "does not perform an ajax request and allows the fetch success be simulated", ->
      successCallback = jasmine.createSpy("successCallback")
      fakeServer.fetch(rel1, rel2).onSuccess(successCallback)

      expect($.ajax).not.toHaveBeenCalled()
      expect(fakeServer.fetches.length).toBe(1)
      expect(fakeServer.lastFetch().relations).toEqual([rel1, rel2])

      fakeServer.lastFetch().succeed
        blogs:
          1:
            title: "Charlie"
            createdAt: 12344
          2:
            title: "Beta"
            createdAt: 12346

      expect(successCallback).toHaveBeenCalled()

      expect(Blog.find(1).title()).toBe("Charlie")
      expect(Blog.find(2).title()).toBe("Beta")

    it "removes the fetch from the fake server's fetches array", ->
      fakeServer.fetch(rel1)
      fetch1 = fakeServer.lastFetch()

      fakeServer.fetch(rel2)
      fetch2 = fakeServer.lastFetch()

      expect(fakeServer.fetches).toEqual([fetch1, fetch2])

      fetch1.succeed({})

      expect(fakeServer.fetches).toEqual([fetch2])

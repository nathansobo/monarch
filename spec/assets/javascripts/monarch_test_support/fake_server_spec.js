describe("Monarch.Remote.FakeServer", function() {

  var fakeServer;

  beforeEach(function() {
    Blog = new JS.Class('Blog', Monarch.Record);
    Blog.columns({
      title: 'string',
      createdAt: 'datetime'
    });

    Monarch.useFakeServer();
    fakeServer = Monarch.Remote.Server;
  });

  afterEach(function() {
    Monarch.restoreOriginalServer();
  });

  describe("creation with the fake server installed", function() {
    it("stores a simulated create request, which can be explicitly completed", function() {
      var promise = Blog.create({title: "Alpha", createdAt: new Date(12345)});
      expect(jQuery.ajax).not.toHaveBeenCalled();

      expect(fakeServer.creates.length).toBe(1);
      var createCommand = fakeServer.lastCreate();
      var record = createCommand.record;
      expect(createCommand).toBe(fakeServer.creates[0]);
      expect(record instanceof Blog).toBeTruthy();
      expect(createCommand.fieldValues).toEqual({title: "Alpha", created_at: 12345});

      var successCallback = jasmine.createSpy("successCallback");
      promise.onSuccess(successCallback);

      createCommand.succeed();
      expect(successCallback).toHaveBeenCalledWith(record);
      expect(record.id()).toBe(1);
      expect(Blog.find(1)).toBe(record);

      // auto-selects the next available id
      Blog.created({id: 5, title: "Bravo"});
      Blog.create({title: "Charlie", createdAt: new Date(12345)});
      var createCommand2 = fakeServer.lastCreate();
      createCommand2.succeed();
      expect(createCommand2.record.id()).toBe(6);
    });

    it("allows simulated response values from the server to be specified for succeed", function() {
      Blog.create({title: "Alpha", createdAt: new Date(12345)});
      var createCommand = fakeServer.lastCreate();

      createCommand.succeed({
        id: 22,
        title: "Zulu",
        created_at: 98765
      });

      var record = createCommand.record;
      expect(record.id()).toBe(22);
      expect(record.title()).toBe("Zulu");
      expect(record.createdAt().getTime()).toBe(98765);
    });

    it("removes the command from the 'creates' array when the create succeeds", function() {
      Blog.create({title: "Alpha", createdAt: new Date(12345)});
      fakeServer.lastCreate().succeed();
      expect(fakeServer.creates.length).toBe(0);

      Blog.create({title: "Bravo"});
      var create1 = fakeServer.lastCreate();
      Blog.create({title: "Charlie"});
      var create2 = fakeServer.lastCreate();

      create1.succeed();

      expect(fakeServer.creates.length).toBe(1);
      expect(fakeServer.lastCreate()).toBe(create2);
    });
  });

  describe("updates with the fake server installed", function() {
    it("stores a simulated update request, which can be explicitly completed", function() {
      var blog = Blog.created({id: 1, title: "Alpha", createdAt: new Date(12345)});
      var promise = blog.update({title: "Bravo", createdAt: new Date(54321)});
      expect(jQuery.ajax).not.toHaveBeenCalled();
      expect(blog.getRemoteField('title').getValue()).toBe("Alpha");
      expect(blog.getRemoteField('createdAt').getValue().getTime()).toBe(12345);

      expect(fakeServer.updates.length).toBe(1);
      var updateCommand = fakeServer.lastUpdate();
      expect(updateCommand).toBe(fakeServer.updates[0]);
      expect(updateCommand.record).toBe(blog);
      expect(updateCommand.fieldValues).toEqual({title: "Bravo", created_at: 54321});

      var successCallback = jasmine.createSpy("successCallback");
      promise.onSuccess(successCallback);

      updateCommand.succeed();
      expect(successCallback).toHaveBeenCalled();
      expect(successCallback.arg(0)).toBe(blog);
      expect(successCallback.arg(1)).toEqual({
        title: {
          oldValue: "Alpha",
          newValue: "Bravo",
          column: Blog.getColumn('title')
        },
        createdAt: {
          oldValue: new Date(12345),
          newValue: new Date(54321),
          column: Blog.getColumn('createdAt')

        }
      });

      expect(blog.title()).toBe("Bravo");
      expect(blog.createdAt().getTime()).toBe(54321);
    });


    it("allows simulated response values from the server to be specified for succeed", function() {
      var blog = Blog.created({id: 1, title: "Alpha", createdAt: new Date(12345)});
      blog.update({title: "Bravo", createdAt: new Date(54321)});

      Blog.create({title: "Alpha", createdAt: new Date(12345)});
      var updateCommand = fakeServer.lastUpdate();

      updateCommand.succeed({
        title: "Zulu",
        created_at: 98765
      });

      expect(blog.title()).toBe("Zulu");
      expect(blog.createdAt().getTime()).toBe(98765);
    });

    it("removes the command from the 'creates' array when the create succeeds", function() {
      var blog = Blog.created({id: 1, title: "Alpha", createdAt: new Date(12345)});
      blog.update({title: "Bravo", createdAt: new Date(54321)});
      fakeServer.lastUpdate().succeed();
      expect(fakeServer.updates.length).toBe(0);

      blog.update({title: "Bravo"});
      var update1 = fakeServer.lastUpdate();
      blog.update({title: "Charlie"});
      var update2 = fakeServer.lastUpdate();

      update1.succeed();

      expect(fakeServer.updates.length).toBe(1);
      expect(fakeServer.lastUpdate()).toBe(update2);
    });
  });

  describe("destroys with the fake server installed", function() {
    it("stores a simulated destroy request, which can be explicitly completed", function() {
      var blog = Blog.created({id: 1, title: "Alpha", createdAt: new Date(12345)});
      var promise = blog.destroy({title: "Bravo", createdAt: new Date(54321)});
      expect(jQuery.ajax).not.toHaveBeenCalled();
      expect(Blog.find(1)).toBe(blog);

      expect(fakeServer.destroys.length).toBe(1);
      var destroyCommand = fakeServer.lastDestroy();
      expect(destroyCommand).toBe(fakeServer.destroys[0]);
      expect(destroyCommand.record).toBe(blog);

      var successCallback = jasmine.createSpy("successCallback");
      promise.onSuccess(successCallback);

      destroyCommand.succeed();
      expect(successCallback).toHaveBeenCalled();
      expect(successCallback.arg(0)).toBe(blog);

      expect(Blog.find(1)).toBeUndefined();
    });

    it("removes the command from the 'destroys' array when the destroy succeeds", function() {
      var blog = Blog.created({id: 1, title: "Alpha", createdAt: new Date(12345)});
      blog.destroy();
      fakeServer.lastDestroy().succeed();
      expect(fakeServer.destroys.length).toBe(0);

      var blog2 = Blog.created({id: 2, title: "Bravo", createdAt: new Date(12345)});
      var blog3 = Blog.created({id: 3, title: "Charlie", createdAt: new Date(12345)});

      blog2.destroy();
      var destroy1 = fakeServer.lastDestroy();
      blog3.destroy();
      var destroy2 = fakeServer.lastDestroy();

      destroy1.succeed();

      expect(fakeServer.destroys.length).toBe(1);
      expect(fakeServer.lastDestroy()).toBe(destroy2);
    });
  });

  describe("when the 'auto' property is true on the fake server", function() {
    it("automatically completes all requests", function() {
      fakeServer.auto = true;

      Blog.create();
      expect(Blog.size()).toBe(1);

      var blog = Blog.first();

      blog.update({title: "Foo"});
      expect(blog.title()).toEqual("Foo");

      blog.destroy();
      expect(Blog.find(blog.id())).toBeUndefined();

      var fetchSuccessCallback = jasmine.createSpy("fetchSuccessCallback");
      Blog.fetch().onSuccess(fetchSuccessCallback);
      expect(fetchSuccessCallback).toHaveBeenCalled();
    });
  });


  describe("fetches with the fake server installed", function() {
    var rel1, rel2;

    beforeEach(function() {
      var rel1 = Blog.where({ 'createdAt >': new Date(12345) });
      var rel2 = Blog.where({ 'title': "Charlie" });
    });

    it("does not perform an ajax request and allows the fetch success be simulated", function() {
      var successCallback = jasmine.createSpy("successCallback");
      fakeServer.fetch(rel1, rel2).onSuccess(successCallback);

      expect($.ajax).not.toHaveBeenCalled();
      expect(fakeServer.fetches.length).toBe(1);
      expect(fakeServer.lastFetch().relations).toEqual([rel1, rel2]);

      fakeServer.lastFetch().succeed({
        blogs: {
          1: {
            title: "Charlie",
            createdAt: 12344
          },
          2: {
            title: "Beta",
            createdAt: 12346
          }
        }
      });

      expect(successCallback).toHaveBeenCalled();

      expect(Blog.find(1).title()).toBe("Charlie");
      expect(Blog.find(2).title()).toBe("Beta");
    });

    it("removes the fetch from the fake server's fetches array", function() {
      fakeServer.fetch(rel1);
      var fetch1 = fakeServer.lastFetch();

      fakeServer.fetch(rel2);
      var fetch2 = fakeServer.lastFetch();

      expect(fakeServer.fetches).toEqual([fetch1, fetch2]);

      fetch1.succeed({});

      expect(fakeServer.fetches).toEqual([fetch2]);
    });
  });
});

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
      expect(record.isA(Blog)).toBeTruthy();
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
});
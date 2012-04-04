describe("Monarch.Remote.Server", function() {
  beforeEach(function() {
    Blog = new JS.Class('Blog', Monarch.Record);
    Blog.columns({
      userId: "integer"
    });
  });

  describe(".fetch", function() {
    var rel1, rel2;

    beforeEach(function() {
      rel1 = Blog.where({userId: 1});
      rel2 = Blog.where({userId: 2});
    });

    it("fetches the given relations' wire representations from the remote repository and updates the repository with them", function() {
      var successHandler = jasmine.createSpy('successHandler');
      var errorHandler = jasmine.createSpy('errorHandler');
      Monarch.fetch(rel1, rel2).onSuccess(successHandler).onError(errorHandler); // Monarch.fetch proxies to Monarch.Remote.Server.fetch

      expect(lastAjaxRequest.url).toBe("/sandbox");
      expect(lastAjaxRequest.type).toBe("get");
      expect(lastAjaxRequest.dataType).toBe('records');
      expect(JSON.parse(lastAjaxRequest.data.relations)).toEqual([rel1.wireRepresentation(), rel2.wireRepresentation()]);

      lastAjaxRequest.success();
      expect(successHandler).toHaveBeenCalled();

      lastAjaxRequest.error();
      expect(errorHandler).toHaveBeenCalled();
    });

    it("accepts an array of relations", function() {
      Monarch.fetch([rel1, rel2]);

      expect(lastAjaxRequest.url).toBe("/sandbox");
      expect(lastAjaxRequest.type).toBe("get");
      expect(lastAjaxRequest.dataType).toBe('records');
      expect(JSON.parse(lastAjaxRequest.data.relations)).toEqual([rel1.wireRepresentation(), rel2.wireRepresentation()]);
    });
  });
});

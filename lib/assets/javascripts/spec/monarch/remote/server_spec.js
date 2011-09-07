describe("Monarch.Remote.Server", function() {
  describe(".fetch", function() {
    it("fetches the given relations' wire representations from the remote repository and updates the repository with them", function() {
      Blog = new JS.Class('Blog', Monarch.Record);
      Blog.columns({
        userId: "integer"
      });

      var rel1 = Blog.where({userId: 1});
      var rel2 = Blog.where({userId: 2});

      Monarch.Remote.Server.fetch(rel1, rel2);

      expect(lastAjaxRequest.url).toBe("/sandbox");
      expect(lastAjaxRequest.type).toBe("get");
      expect(JSON.parse(lastAjaxRequest.data.relations)).toEqual([rel1.wireRepresentation(), rel2.wireRepresentation()]);
    });
  });
});
describe "Monarch.Remote.Server", ->
  Blog = null
  beforeEach ->
    class Blog extends Monarch.Record
      @inherited(this)
      @columns(userId: "integer")

  describe ".fetch", ->
    [rel1, rel2] = []

    beforeEach ->
      rel1 = Blog.where(userId: 1)
      rel2 = Blog.where(userId: 2)

    it "fetches the given relations' wire representations from the remote repository and updates the repository with them", ->
      successHandler = jasmine.createSpy('successHandler')
      errorHandler = jasmine.createSpy('errorHandler')
      Monarch.fetch(rel1, rel2).onSuccess(successHandler).onError(errorHandler); # Monarch.fetch proxies to Monarch.Remote.Server.fetch

      expect(lastAjaxRequest.url).toBe("/sandbox")
      expect(lastAjaxRequest.type).toBe("get")
      expect(lastAjaxRequest.dataType).toBe('records')
      expect(JSON.parse(lastAjaxRequest.data.relations)).toEqual([rel1.wireRepresentation(), rel2.wireRepresentation()])

      lastAjaxRequest.success()
      expect(successHandler).toHaveBeenCalled()

      lastAjaxRequest.error()
      expect(errorHandler).toHaveBeenCalled()

    it "accepts an array of relations", ->
      Monarch.fetch([rel1, rel2])

      expect(lastAjaxRequest.url).toBe("/sandbox")
      expect(lastAjaxRequest.type).toBe("get")
      expect(lastAjaxRequest.dataType).toBe('records')
      expect(JSON.parse(lastAjaxRequest.data.relations)).toEqual([rel1.wireRepresentation(), rel2.wireRepresentation()])

describe "custom ajax dataType converters", ->
  [User, Blog] = []
  beforeEach ->
    mockLowLevelXhr()

    class User extends Monarch.Record
      @extended(this)
      @columns(fullName: 'string')

    class Blog extends Monarch.Record
      @extended(this)
      @columns(title: 'string')

  describe "handling requests with the 'records' dataType", ->
    it "updates the repository with the returned records before invoking the success callback", ->
      successCallback = jasmine.createSpy('successCallback')
      successCallback.plan = ->
        expect(User.find(1).fullName()).toBe("Adam Smith")
        expect(Blog.find(1).title()).toBe("Blog 1")
        expect(Blog.find(2).title()).toBe("Blog 2")

      jQuery.ajax
        url: '/resource',
        dataType: 'records',
        success: successCallback

      recordsHash =
        'users':
          '1':
            id: 1
            fullName: "Adam Smith"
        'blogs':
          '1':  id: 1, title: "Blog 1"
          '2':  id: 2, title: "Blog 2"

      lastAjaxRequest.response
        status: 200,
        contentType: 'application/json',
        responseText: JSON.stringify(recordsHash)

      expect(successCallback).toHaveBeenCalled()

  describe "handling requests with the 'records!' dataType", ->
    it "clears and then updates the repository with the returned records before invoking the success callback", ->
      successCallback = jasmine.createSpy('successCallback')
      successCallback.plan = ->
        expect(User.find(99)).toBeUndefined()
        expect(User.find(1).fullName()).toBe("Adam Smith")
        expect(Blog.find(1).title()).toBe("Blog 1")
        expect(Blog.find(2).title()).toBe("Blog 2")

      User.created(id: 99)

      jQuery.ajax
        url: '/resource',
        dataType: 'records!',
        success: successCallback

      expect(User.find(99)).not.toBeUndefined()

      recordsHash =
        'users':
          '1':
            id: 1
            fullName: "Adam Smith"
        'blogs':
          '1':  id: 1, title: "Blog 1"
          '2':  id: 2, title: "Blog 2"

      lastAjaxRequest.response
        status: 200,
        contentType: 'application/json',
        responseText: JSON.stringify(recordsHash)

      expect(successCallback).toHaveBeenCalled()

  describe "handling requests with the 'data+records' dataType", ->
    it "updates the repository with the records returned under the top-level 'records' key, then invokes callbacks with the 'data' key", ->
      successCallback = jasmine.createSpy('successCallback')
      successCallback.plan = ->
        expect(User.find(1).fullName()).toBe("Adam Smith")
        expect(Blog.find(1).title()).toBe("Blog 1")
        expect(Blog.find(2).title()).toBe("Blog 2")

      jQuery.ajax
        url: '/resource',
        dataType: 'data+records',
        success: successCallback

      data = { foo: [1, 2], bar: "baz" }

      responseJson =
        data: data
        records:
          users:
            1: { id: 1, fullName: "Adam Smith" }
          blogs:
            1: { id: 1, title: "Blog 1" }
            2: { id: 2, title: "Blog 2" }

      lastAjaxRequest.response
        status: 200,
        contentType: 'application/json',
        responseText: JSON.stringify(responseJson)

      expect(successCallback).toHaveBeenCalled()
      expect(successCallback.arg(0)).toEqual(data)

  describe "handling requests with the 'data+records!' dataType", ->
    it "clears the repository, then updates it as normal before invoking callbacks with the 'data' key", ->
      successCallback = jasmine.createSpy('successCallback')
      successCallback.plan = ->
        expect(User.find(99)).toBeUndefined()
        expect(User.find(1).fullName()).toBe("Adam Smith")
        expect(Blog.find(1).title()).toBe("Blog 1")
        expect(Blog.find(2).title()).toBe("Blog 2")

      User.created(id: 99)

      jQuery.ajax
        url: '/resource',
        dataType: 'data+records!',
        success: successCallback

      data = { foo: [1, 2], bar: "baz" }

      responseJson =
        data: data,
        records:
          users:
            1: { id: 1, fullName: "Adam Smith" }
          blogs:
            1: { id: 1, title: "Blog 1" }
            2: { id: 2, title: "Blog 2" }

      lastAjaxRequest.response
        status: 200,
        contentType: 'application/json',
        responseText: JSON.stringify(responseJson)

      expect(successCallback).toHaveBeenCalled()
      expect(successCallback.arg(0)).toEqual(data)

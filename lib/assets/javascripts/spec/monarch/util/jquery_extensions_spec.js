describe("custom ajax dataType converters", function() {
  beforeEach(function() {
    mockLowLevelXhr();
    User = new JS.Class('User', Monarch.Record);
    User.columns({ fullName: 'string' });
    Blog = new JS.Class('Blog', Monarch.Record);
    Blog.columns({ title: 'string' });
  });

  describe("handling requests with the 'records' dataType", function() {
    it("updates the repository with the returned records before invoking the success callback", function() {
      var successCallback = jasmine.createSpy('successCallback');
      successCallback.plan = function() {
        expect(User.find(1).fullName()).toBe("Adam Smith");
        expect(Blog.find(1).title()).toBe("Blog 1");
        expect(Blog.find(2).title()).toBe("Blog 2");
      };

      jQuery.ajax({
        url: '/resource',
        dataType: 'records',
        success: successCallback
      });

      var recordsHash = {
        'users': {
          '1': {
            id: 1,
            fullName: "Adam Smith"
          }
        },
        'blogs': {
          '1': { id: 1, title: "Blog 1" },
          '2': { id: 2, title: "Blog 2" }
        }
      };

      lastAjaxRequest.response({
        status: 200,
        contentType: 'application/json',
        responseText: JSON.stringify(recordsHash)
      });

      expect(successCallback).toHaveBeenCalled();
    });
  });

  describe("handling requests with the 'records!' dataType", function() {
    it("clears and then updates the repository with the returned records before invoking the success callback", function() {
      var successCallback = jasmine.createSpy('successCallback');
      successCallback.plan =  function() {
        expect(User.find(99)).toBeUndefined();
        expect(User.find(1).fullName()).toBe("Adam Smith");
        expect(Blog.find(1).title()).toBe("Blog 1");
        expect(Blog.find(2).title()).toBe("Blog 2");
      };

      User.created({id: 99});

      jQuery.ajax({
        url: '/resource',
        dataType: 'records!',
        success: successCallback
      });

      expect(User.find(99)).not.toBeUndefined();

      var recordsHash = {
        'users': {
          '1': {
            id: 1,
            fullName: "Adam Smith"
          }
        },
        'blogs': {
          '1': { id: 1, title: "Blog 1" },
          '2': { id: 2, title: "Blog 2" }
        }
      };

      lastAjaxRequest.response({
        status: 200,
        contentType: 'application/json',
        responseText: JSON.stringify(recordsHash)
      });

      expect(successCallback).toHaveBeenCalled();
    });
  });

  describe("handling requests with the 'data+records' dataType", function() {
    it("updates the repository with the records returned under the top-level 'records' key, then invokes callbacks with the 'data' key", function() {
      var successCallback = jasmine.createSpy('successCallback');
      successCallback.plan = function() {
        expect(User.find(1).fullName()).toBe("Adam Smith");
        expect(Blog.find(1).title()).toBe("Blog 1");
        expect(Blog.find(2).title()).toBe("Blog 2");
      };

      jQuery.ajax({
        url: '/resource',
        dataType: 'data+records',
        success: successCallback
      });

      var data = {
        foo: [1, 2],
        bar: "baz"
      };

      var responseJson = {
        data: data,
        records: {
          users: {
            1: { id: 1, fullName: "Adam Smith" }
          },
          blogs: {
            1: { id: 1, title: "Blog 1" },
            2: { id: 2, title: "Blog 2" }
          }
        }
      };

      lastAjaxRequest.response({
        status: 200,
        contentType: 'application/json',
        responseText: JSON.stringify(responseJson)
      });

      expect(successCallback).toHaveBeenCalled();
      expect(successCallback.arg(0)).toEqual(data);
    });
  });

  describe("handling requests with the 'data+records!' dataType", function() {
    it("clears the repository, then updates it as normal before invoking callbacks with the 'data' key", function() {
      var successCallback = jasmine.createSpy('successCallback');
      successCallback.plan = function() {
        expect(User.find(99)).toBeUndefined();
        expect(User.find(1).fullName()).toBe("Adam Smith");
        expect(Blog.find(1).title()).toBe("Blog 1");
        expect(Blog.find(2).title()).toBe("Blog 2");
      };

      User.created({id: 99});

      jQuery.ajax({
        url: '/resource',
        dataType: 'data+records!',
        success: successCallback
      });

      var data = {
        foo: [1, 2],
        bar: "baz"
      };

      var responseJson = {
        data: data,
        records: {
          users: {
            1: { id: 1, fullName: "Adam Smith" }
          },
          blogs: {
            1: { id: 1, title: "Blog 1" },
            2: { id: 2, title: "Blog 2" }
          }
        }
      };

      lastAjaxRequest.response({
        status: 200,
        contentType: 'application/json',
        responseText: JSON.stringify(responseJson)
      });

      expect(successCallback).toHaveBeenCalled();
      expect(successCallback.arg(0)).toEqual(data);
    });
  });
});

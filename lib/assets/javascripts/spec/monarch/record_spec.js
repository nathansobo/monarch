//= require spec/spec_helper

describe("Record", function() {
  describe("class methods", function() {
    beforeEach(function() {
      BlogPost = new JS.Class('BlogPost', Monarch.Record);
    });

    afterEach(function() {
      delete window.BlogPost;
    });

    describe(".inherited(subclass)", function() {
      it("associates subclasses with a table in the repository", function() {
        expect(BlogPost.displayName).toBe('BlogPost');
        expect(BlogPost.table.isA(Monarch.Relations.Table)).toBeTruthy();
        expect(BlogPost.table.name).toBe('blog_posts');
        expect(BlogPost.table).toEqual(Monarch.Repository.tables.blog_posts);
      });

      it("automatically defines an integer-typed id column", function() {
        expect(BlogPost.id.isA(Monarch.Expressions.Column)).toBeTruthy();
        expect(BlogPost.id).toBe(BlogPost.table.getColumn('id'));
        expect(BlogPost.id.type).toBe('integer');
      });
    });
    
    describe(".defineColumn(name, type)", function() {
      it("defines a column on the table", function() {
        BlogPost.defineColumn('title', 'string');
        expect(BlogPost.title).toBe(BlogPost.table.getColumn('title'));
        expect(BlogPost.title.isA(Monarch.Expressions.Column)).toBeTruthy();
        expect(BlogPost.title.type).toBe('string');
      });
    });

    describe(".defineColumns(hash)", function() {
      it("defines all columns in the given hash", function() {
        BlogPost.defineColumns({
          title: 'string',
          body: 'string'
        });

        expect(BlogPost.title).not.toBeUndefined();
        expect(BlogPost.title.type).toBe('string');
        
        expect(BlogPost.body).not.toBeUndefined();
        expect(BlogPost.body.type).toBe('string');
      });
    });

    describe(".create(attrs)", function() {
      var promise;

      beforeEach(function() {
        BlogPost.defineColumns({
          title: 'string',
          body: 'string'
        });

        promise = BlogPost.create({title: "Testing", body: "1 2 3"});
      });

      it("sends a create command to the server", function() {
        expect(lastAjaxRequest.url).toBe('/sandbox');
        expect(lastAjaxRequest.type).toBe('post');
        expect(JSON.parse(lastAjaxRequest.data)).toEqual(['create', 'blog_posts', { title: "Testing", body: "1 2 3" }]);
      });

      describe("when the server creates the record successfully", function() {
        it("assigns the remote fields with the attributes from the server, inserts it into its table, and triggers success on the promise", function() {
          var onSuccessCallback = jasmine.createSpy('onSuccessCallback')
          promise.onSuccess(onSuccessCallback);

          lastAjaxRequest.success({
            title: "Testing +",
            body: "1 2 3 +"
          });

          expect(onSuccessCallback).toHaveBeenCalled();
          var record = onSuccessCallback.mostRecentCall.args[0];
          expect(record.isA(Monarch.Record)).toBeTruthy();

          expect(record.title()).toBe("Testing +");
          expect(record.body()).toBe("1 2 3 +");
        });
      });

      describe("when the server has an error creating the record", function() {

      });
    });
  });

  describe("instance methods", function() {
    beforeEach(function() {
      BlogPost = new JS.Class('BlogPost', Monarch.Record);
      BlogPost.defineColumns({
        title: 'string',
        body: 'string'
      });
    });

    describe("#initialize", function() {
      it("builds fields for each of the table's columns", function() {
        var post = new BlogPost();
        expect(post.getField('title').column).toBe(BlogPost.title);
        expect(post.getField('body').column).toBe(BlogPost.body);
      });
    });
  });
});
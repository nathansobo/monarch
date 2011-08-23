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
  });
});
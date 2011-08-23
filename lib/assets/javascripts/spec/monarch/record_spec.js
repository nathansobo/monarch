//= require spec/spec_helper

describe("Record", function() {
  describe("class methods", function() {
    describe(".inherited", function() {
      it("associates subclasses with a table in the repository", function() {
        var BlogPost = new JS.Class('BlogPost', Monarch.Record);
        expect(BlogPost.displayName).toBe('BlogPost');
        expect(BlogPost.table.isA(Monarch.Relations.Table)).toBeTruthy();
        expect(BlogPost.table.name).toBe('blog_posts');
        expect(BlogPost.table).toEqual(Monarch.Repository.tables.blog_posts);
      });
    });
  });
});
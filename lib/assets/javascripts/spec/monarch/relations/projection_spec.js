//= require spec/spec_helper

describe("Monarch.Relations.Projection", function() {

  beforeEach(function() {
    User = new JS.Class('User', Monarch.Record);
    User.columns({
      premium: 'boolean'
    });

    Blog = new JS.Class('Blog', Monarch.Record);
    Blog.columns({
      userId: 'integer',
      title: 'string'
    });
    Blog.defaultOrderBy('title');

    BlogPost = new JS.Class('BlogPost', Monarch.Record);
    BlogPost.columns({
      blogId: 'integer',
      title: 'string'
    });
    BlogPost.defaultOrderBy('title');
  });

  describe("#all", function() {
    it("extracts records corresponding to the projected table from the underlying composite tuples", function() {
      User.remotelyCreated({id: 1, premium: true});
      User.remotelyCreated({id: 2, premium: false});
      Blog.remotelyCreated({id: 1, userId: 1, title: "Alpha"});
      Blog.remotelyCreated({id: 2, userId: 1, title: "Bravo"});
      Blog.remotelyCreated({id: 3, userId: 2, title: "Charlie"});
      var post1 = BlogPost.remotelyCreated({id: 1, blogId: 1, title: "Alpha"});
      var post2 = BlogPost.remotelyCreated({id: 2, blogId: 1, title: "Bravo"});
      var post3 = BlogPost.remotelyCreated({id: 3, blogId: 2, title: "Charlie"});
      BlogPost.remotelyCreated({id: 4, blogId: 3, title: "Delta"});

      var records = User.where({premium: true}).join(Blog).joinThrough(BlogPost).all();
      expect(records).toEqual([post1, post2, post3]);
    });
  });

  describe("#isEqual(other)", function() {
    it("determines structural equality", function() {
      var projection1 = Blog.where({userId: 1}).joinThrough(BlogPost);
      var projection2 = Blog.where({userId: 1}).joinThrough(BlogPost);
      expect(projection1).toEqual(projection2);
    });
  });
});
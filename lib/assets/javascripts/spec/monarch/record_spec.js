describe("Monarch.Record", function() {
  describe("class methods", function() {
    beforeEach(function() {
      BlogPost = new JS.Class('BlogPost', Monarch.Record);
    });

    describe(".inherited(subclass)", function() {
      it("associates subclasses with a table in the repository", function() {
        expect(BlogPost.displayName).toBe('BlogPost');
        expect(BlogPost.table.isA(Monarch.Relations.Table)).toBeTruthy();
        expect(BlogPost.table.name).toBe('BlogPost');
        expect(BlogPost.table.remoteName).toBe('blog_posts');
        expect(BlogPost.table).toEqual(Monarch.Repository.tables.BlogPost);
      });

      it("automatically defines an integer-typed id column", function() {
        expect(BlogPost.id.isA(Monarch.Expressions.Column)).toBeTruthy();
        expect(BlogPost.id).toBe(BlogPost.table.getColumn('id'));
        expect(BlogPost.id.type).toBe('integer');
      });
    });
    
    describe(".column(name, type)", function() {
      it("defines a column on the table", function() {
        BlogPost.column('title', 'string');
        expect(BlogPost.title).toBe(BlogPost.table.getColumn('title'));
        expect(BlogPost.title.isA(Monarch.Expressions.Column)).toBeTruthy();
        expect(BlogPost.title.type).toBe('string');
      });
    });

    describe(".columns(hash)", function() {
      it("defines all columns in the given hash", function() {
        BlogPost.columns({
          title: 'string',
          body: 'string'
        });

        expect(BlogPost.title).not.toBeUndefined();
        expect(BlogPost.title.type).toBe('string');
        
        expect(BlogPost.body).not.toBeUndefined();
        expect(BlogPost.body.type).toBe('string');
      });
    });

    describe(".syntheticColumn(name, signalDefinition)", function() {
      it("causes records to have synthetic fields based on signals that can change", function() {
        BlogPost.column('title', 'string');
        BlogPost.syntheticColumn('titlePrime', function() {
          return this.signal('title', function(title) {
            return title + " Prime";
          });
        });

        var post = BlogPost.created({id: 1, title: "Foo"})
        expect(post.titlePrime()).toBe("Foo Prime");

        // signals are included in changesets produced during updates
        var onSuccessCallback = jasmine.createSpy('onSuccessCallback');
        post.update({title: "Bar"}).onSuccess(onSuccessCallback);
        lastAjaxRequest.success({title: "Bar"});
        expect(onSuccessCallback).toHaveBeenCalled();
        expect(onSuccessCallback.mostRecentCall.args[1]).toEqual({
          title: {
            newValue: "Bar",
            oldValue: "Foo",
            column: BlogPost.title
          },

          titlePrime: {
            newValue: "Bar Prime",
            oldValue: "Foo Prime",
            column: BlogPost.titlePrime
          }
        });
      });
    });

    describe(".hasMany", function() {
      it("defines a hasMany relation", function() {
        Comment = new JS.Class('Comment', Monarch.Record);
        Comment.columns({blogPostId: 'integer'});
        BlogPost.hasMany('comments');

        var post = BlogPost.created({id: 1});
        expect(post.comments()).toEqual(Comment.where({blogPostId: 1}));
      });

      it("supports a 'className' option", function() {
        
      });

      it("supports a 'foreignKey' option", function() {

      });

      it("supports an 'orderBy' option", function() {

      });

      it("supports a 'conditions' option", function() {

      });


      it("supports a 'through' option", function() {

      });
    });

    describe(".relatesTo(name, definition)", function() {
      it("defines a method that returns a memoized relation given by the definition", function() {
        Comment = new JS.Class('Comment', Monarch.Record);
        Comment.columns({postId: 'integer', public: 'boolean'});

        BlogPost.relatesTo('comments', function() {
          return Comment.where({postId: this.id()});
        });
        BlogPost.relatesTo('publicComments', function() {
          return Comment.where({postId: this.id(), public: true});
        });
        var post = BlogPost.created({id: 1});

        expect(post.comments()).toEqual(Comment.where({postId: 1}));
        expect(post.comments()).toBe(post.comments()); // memoized

        expect(post.comments()).not.toBe(post.publicComments());
      });
    });

    describe(".create(attrs)", function() {
      var promise;

      beforeEach(function() {
        BlogPost.columns({
          title: 'string',
          body: 'string'
        });

        promise = BlogPost.create({title: "Testing", body: "1 2 3"});
      });

      it("sends a create command to the server", function() {
        expect(lastAjaxRequest.url).toBe('/sandbox/blog_posts');
        expect(lastAjaxRequest.type).toBe('post');
        expect(lastAjaxRequest.data).toEqual({field_values: { title: "Testing", body: "1 2 3" }});
      });

      describe("when the server creates the record successfully", function() {
        it("assigns the remote fields with the attributes from the server, inserts it into its table, and triggers success on the promise", function() {
          var onSuccessCallback = jasmine.createSpy('onSuccessCallback');
          promise.onSuccess(onSuccessCallback);

          lastAjaxRequest.success({
            id: 23,
            title: "Testing +",
            body: "1 2 3 +"
          });

          expect(onSuccessCallback).toHaveBeenCalled();
          var post = onSuccessCallback.mostRecentCall.args[0];
          expect(post.isA(Monarch.Record)).toBeTruthy();
          expect(post.id()).toBe(23);
          expect(post.title()).toBe("Testing +");
          expect(post.body()).toBe("1 2 3 +");
          expect(BlogPost.contains(post)).toBeTruthy();
        });
      });

      describe("when the server responds with validation errors", function() {
        it("assigns validation errors on the record and marks it invalid", function() {
          var onInvalidCallback = jasmine.createSpy('onInvalidCallback');
          promise.onInvalid(onInvalidCallback);

          lastAjaxRequest.error({
            status: 422,
            responseText: JSON.stringify({
              title: ["Error message 1", "Error message 2"],
              body: ["Error message 3"]
            })
          });
          
          expect(onInvalidCallback).toHaveBeenCalled();
          var post = onInvalidCallback.mostRecentCall.args[0];
          expect(post.isA(Monarch.Record)).toBeTruthy();
          expect(post.isValid()).toBeFalsy();
          expect(post.errors.on('title')).toEqual(["Error message 1", "Error message 2"]);
          expect(post.errors.on('body')).toEqual(["Error message 3"]);
        });
      });
    });
  });

  describe("instance methods", function() {
    beforeEach(function() {
      BlogPost = new JS.Class('BlogPost', Monarch.Record);
      BlogPost.columns({
        blogId: 'integer',
        title: 'string',
        body: 'string'
      });
    });

    describe("#initialize()", function() {
      it("builds fields for each of the table's columns", function() {
        var post = new BlogPost();
        expect(post.getField('title').column).toBe(BlogPost.title);
        expect(post.getField('body').column).toBe(BlogPost.body);
      });
    });

    describe("#save()", function() {
      var promise;

      describe("when the record has already been created", function() {
        var post;
        beforeEach(function() {
          post = BlogPost.created({id: 1, blogId: 1, title: 'Title', body: 'Body'});
          expect(post.isDirty()).toBeFalsy();

          post.localUpdate({ blogId: 2, body: 'Body++'});
          expect(post.isDirty()).toBeTruthy();
          promise = post.save();
          expect(post.isDirty()).toBeTruthy();
        });

        it("sends the dirty fields to the server in a put to the record's url", function() {
          expect(lastAjaxRequest.url).toBe('/sandbox/blog_posts/1');
          expect(lastAjaxRequest.type).toBe('put');
          expect(lastAjaxRequest.data).toEqual({ field_values: { blog_id: 2,body : "Body++"}});
        });

        describe("when the server updates the record successfully", function() {
          it("updates the record with the attributes returned and triggers success on the promise with the record and a change set", function() {
            var onSuccessCallback = jasmine.createSpy('onSuccessCallback')
            promise.onSuccess(onSuccessCallback);

            lastAjaxRequest.success({
              blog_id: 2,
              body: "Body+++"
            });

            expect(onSuccessCallback).toHaveBeenCalled();
            
            expect(onSuccessCallback.mostRecentCall.args[0]).toBe(post);
            expect(post.isA(Monarch.Record)).toBeTruthy();
            expect(post.blogId()).toBe(2);
            expect(post.body()).toBe("Body+++");
            expect(post.isDirty()).toBeFalsy();

            expect(onSuccessCallback.mostRecentCall.args[1]).toEqual({
              blogId: {
                oldValue: 1,
                newValue: 2,
                column: BlogPost.blogId
              },
              body: {
                oldValue: "Body",
                newValue: "Body+++",
                column: BlogPost.body
              }
            });
          });
        });

        describe("update hooks", function() {
          it("invokes beforeUpdate and afterUpdate hooks if present on the record", function() {
            var post = BlogPost.created({id: 1, title: "Alpha", body: "Bravo"});
            spyOn(post, 'beforeUpdate');
            spyOn(post, 'afterUpdate');

            post.save();

            expect(post.beforeUpdate).toHaveBeenCalled();
            expect(post.afterUpdate).not.toHaveBeenCalled();

            lastAjaxRequest.success({
              id: 23,
              title: "Good Title+",
              body: "Good Body+"
            });

            expect(post.afterUpdate).toHaveBeenCalled();
          });

          it("does not proceed with the creation if beforeCreate returns 'false'", function() {
            $.ajax.reset();
            var post = BlogPost.created({id: 1, title: "Alpha", body: "Bravo"});
            spyOn(post, 'beforeUpdate').andReturn(false);

            post.save();

            expect(post.beforeUpdate).toHaveBeenCalled();
            expect($.ajax).not.toHaveBeenCalled();
          });
        });

        describe("when the server responds with validation errors", function() {
          it("assigns validation errors on the record and marks it invalid", function() {
            var onInvalidCallback = jasmine.createSpy('onInvalidCallback')
            promise.onInvalid(onInvalidCallback);

            lastAjaxRequest.error({
              status: 422,
              responseText: JSON.stringify({
                title: ["Error message 1", "Error message 2"],
                body: ["Error message 3"]
              })
            });

            expect(onInvalidCallback).toHaveBeenCalled();
            var post = onInvalidCallback.mostRecentCall.args[0];
            expect(post.isA(Monarch.Record)).toBeTruthy();
            expect(post.isValid()).toBeFalsy();
            expect(post.errors.on('title')).toEqual(["Error message 1", "Error message 2"]);
            expect(post.errors.on('body')).toEqual(["Error message 3"]);
          });
        });
      });

      describe("when the record has not yet been created", function() {
        beforeEach(function() {
          var record;
          BlogPost.create({title: "Bad Title", body: "Bad Body"}).onInvalid(function(r) {
            record = r;
          });

          lastAjaxRequest.error({
            status: 422,
            responseText: JSON.stringify({
              title: ["Error message 1"],
              body: ["Error message 2"]
            })
          });

          expect(record.isValid()).toBeFalsy();

          record.localUpdate({title: "Good Title", body: "Good Body"});
          promise = record.save();
        });

        it("sends a create command to the server", function() {
          expect(lastAjaxRequest.url).toBe('/sandbox/blog_posts');
          expect(lastAjaxRequest.type).toBe('post');
          expect(lastAjaxRequest.data).toEqual({field_values: { title: "Good Title", body: "Good Body" }});
        });

        describe("if the server responds successfully", function() {
          it("inserts the record and clears validation errors", function() {
            var onSuccessCallback = jasmine.createSpy('onSuccessCallback');
            promise.onSuccess(onSuccessCallback);

            lastAjaxRequest.success({
              id: 23,
              title: "Good Title+",
              body: "Good Body+"
            });

            expect(onSuccessCallback).toHaveBeenCalled();
            var post = onSuccessCallback.mostRecentCall.args[0];
            expect(post.isA(Monarch.Record)).toBeTruthy();
            expect(post.id()).toBe(23);
            expect(post.title()).toBe("Good Title+");
            expect(post.body()).toBe("Good Body+");
            expect(BlogPost.contains(post)).toBeTruthy();
            expect(post.isValid()).toBeTruthy();
          });
        });

        describe("create hooks", function() {
          it("invokes beforeCreate and afterCreate hooks if present on the record", function() {
            var post = new BlogPost({title: "Alpha", body: "Bravo"});
            spyOn(post, 'beforeCreate');
            spyOn(post, 'afterCreate');

            post.save();

            expect(post.beforeCreate).toHaveBeenCalled();
            expect(post.afterCreate).not.toHaveBeenCalled();

            lastAjaxRequest.success({
              id: 23,
              title: "Good Title+",
              body: "Good Body+"
            });

            expect(post.afterCreate).toHaveBeenCalled();
          });

          it("does not proceed with the creation if beforeCreate returns 'false'", function() {
            $.ajax.reset();
            var post = new BlogPost({title: "Alpha", body: "Bravo"});
            spyOn(post, 'beforeCreate').andReturn(false);

            post.save();

            expect(post.beforeCreate).toHaveBeenCalled();
            expect($.ajax).not.toHaveBeenCalled();
          });
        });
      });
    });

    describe("#destroy()", function() {
      it("sends a delete request to the record's url, then removes it from the repository", function() {
        var post = BlogPost.created({id: 44, title: "Title"});
        var promise = post.destroy();
        expect(BlogPost.contains(post)).toBeTruthy(); // waits for server

        expect(lastAjaxRequest.url).toBe('/sandbox/blog_posts/44');
        expect(lastAjaxRequest.type).toBe('delete');

        var onSuccessCallback = jasmine.createSpy('onSuccessCallback')
        promise.onSuccess(onSuccessCallback);

        lastAjaxRequest.success();

        expect(onSuccessCallback).toHaveBeenCalled();
        expect(BlogPost.contains(post)).toBeFalsy();
      });

      describe("destroy hooks", function() {
        it("invokes beforeDestroy and afterDestroy hooks", function() {
          var post = BlogPost.created({id: 44, title: "Title"});
          spyOn(post, 'beforeDestroy');
          spyOn(post, 'afterDestroy');

          post.destroy();

          expect(post.beforeDestroy).toHaveBeenCalled();
          expect(post.afterDestroy).not.toHaveBeenCalled();

          lastAjaxRequest.success();

          expect(post.afterDestroy).toHaveBeenCalled();
        });

        it("does not proceed with the destroy if the beforeDestroy hook returns 'false'", function() {
          $.ajax.reset();
          var post = BlogPost.created({id: 44, title: "Title"});
          spyOn(post, 'beforeDestroy').andReturn(false);

          post.destroy();

          expect($.ajax).not.toHaveBeenCalled();
        });
      });
    });

    describe("#signal(fieldName)", function() {
      it("returns a signal based on the value of the field that responds to it changing", function() {
        var post = BlogPost.created({id: 1, title: "Title"});

        var signal = post.signal('title', function(title) {
          return title + " Prime";
        });

        expect(signal.getValue()).toBe("Title Prime");

        var onChangeCallback = jasmine.createSpy('onChangeCallback');

        signal.onChange(onChangeCallback);

        post.updated({title: "Foo"});

        expect(onChangeCallback).toHaveBeenCalledWith("Foo Prime", "Title Prime");
      });
    });

    describe("#getField(name)", function() {
      it("accepts qualified and unqualified names, ensuring the qualifier matches the table name", function() {
        var post = BlogPost.created({id: 1, title: "Title"});

        expect(post.getField('title').getValue()).toBe("Title");
        expect(post.getField('BlogPost.title').getValue()).toBe("Title");
        expect(post.getField('FooBar.title')).toBeUndefined();
      });
    });
  });
});

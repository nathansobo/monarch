describe "Monarch.Record", ->
  describe "class methods", ->
    BlogPost = null

    beforeEach ->
      class BlogPost extends Monarch.Record
        @extended(this)

    describe "@extended(subclass)", ->
      it "associates subclasses with a table in the repository", ->
        expect(BlogPost.name).toBe('BlogPost')
        expect(BlogPost.table instanceof Monarch.Relations.Table).toBeTruthy()
        expect(BlogPost.table.name).toBe('BlogPost')
        expect(BlogPost.table).toEqual(Monarch.Repository.tables.BlogPost)

      it "automatically defines an id column", ->
        expect(BlogPost.table.getColumn('id').type).toBe('key')

    describe "@column(name, type)", ->
      it "defines a column on the table", ->
        BlogPost.column('title', 'string')

        column = BlogPost.table.getColumn('title')
        expect(column instanceof Monarch.Expressions.Column).toBeTruthy()
        expect(column.type).toBe('string')

    describe "@columns(hash)", ->
      it "defines all columns in the given hash", ->
        BlogPost.columns
          title: 'string'
          body: 'string'

        expect(BlogPost.getColumn('title')).not.toBeUndefined()
        expect(BlogPost.getColumn('title').type).toBe('string')

        expect(BlogPost.getColumn('body')).not.toBeUndefined()
        expect(BlogPost.getColumn('body').type).toBe('string')

    describe "@syntheticColumn(name, signalDefinition)", ->
      it "causes records to have synthetic fields based on signals that can change", ->
        BlogPost.column('title', 'string')
        BlogPost.syntheticColumn 'titlePrime', ->
          this.signal 'title', (title) -> title + " Prime"

        post = BlogPost.created(id: 1, title: "Foo")
        expect(post.titlePrime()).toBe("Foo Prime")

        # signals are included in changesets produced during updates
        onSuccessCallback = jasmine.createSpy('onSuccessCallback')
        post.update(title: "Bar").onSuccess(onSuccessCallback)
        expect(post.titlePrime()).toBe "Bar Prime"

        lastAjaxRequest.success(title: "Bar+")
        expect(onSuccessCallback).toHaveBeenCalled()

        expect(onSuccessCallback.mostRecentCall.args[1]).toEqual(
          title:
            newValue: "Bar+"
            oldValue: "Bar"
            column: BlogPost.getColumn('title')

          titlePrime:
            newValue: "Bar+ Prime"
            oldValue: "Bar Prime"
            column: BlogPost.getColumn('titlePrime')
        )

    describe "@hasMany", ->
      it "defines a hasMany relation", ->
        expect(BlogPost.hasMany('comments')).toBe(BlogPost)

        class Comment extends Monarch.Record
          @extended(this)
          @columns(blogPostId: 'integer')

        post = BlogPost.created(id: 1)
        expect(post.comments()).toEqual(Comment.where({blogPostId: 1}))

      it "supports a 'className' option", ->
        class PostComment extends Monarch.Record
          @extended(this)
          @columns(blogPostId: 'integer')

        BlogPost.hasMany('comments', className: 'PostComment')

        post = BlogPost.created(id: 1)
        expect(post.comments()).toEqual(PostComment.where(blogPostId: 1))

      it "supports a 'foreignKey' option", ->
        class Comment extends Monarch.Record
          @extended(this)
          @columns(postId: 'integer')

        BlogPost.hasMany('comments', foreignKey: 'postId')

        post = BlogPost.created(id: 1)
        expect(post.comments()).toEqual(Comment.where(postId: 1))

      it "supports an 'orderBy' option", ->
        class Comment extends Monarch.Record
          @extended(this)
          @columns(blogPostId: 'integer', body: 'string', createdAt: 'datetime')

        BlogPost.hasMany('comments', orderBy: 'body desc')
        post1 = BlogPost.created(id: 1)
        expect(post1.comments()).toEqual(Comment.where({blogPostId: 1}).orderBy('body desc'))

        BlogPost.hasMany('comments', orderBy: ['body desc', 'createdAt'])
        post2 = BlogPost.created(id: 2)
        expect(post2.comments()).toEqual(Comment.where({blogPostId: 2}).orderBy('body desc', 'createdAt'))

      it "supports a 'conditions' option", ->
        class Comment extends Monarch.Record
          @extended(this)
          @columns(blogPostId: 'integer', public: 'boolean', score: 'integer')

        BlogPost.hasMany('comments', conditions: { public: true, 'score >': 3 })
        post = BlogPost.created(id: 1)
        # conditions are turned into an 'and' tree, and may be order sensitive. chrome seems to respect lexical order
        expect(post.comments()).toEqual(Comment.where({ public: true, 'score >': 3, blogPostId: 1 }))

      it "supports a 'through' option", ->
        class Blog extends Monarch.Record
          @extended(this)
          @hasMany('posts', className: 'BlogPost')
          @hasMany('comments', through: 'posts')

        class Comment extends Monarch.Record
          @extended(this)
          @columns(blogPostId: 'integer')

        BlogPost.columns(blogId: 'integer')

        blog = Blog.created(id: 1)
        expect(blog.comments()).toEqual(blog.posts().joinThrough(Comment))

    describe "@relatesTo(name, definition)", ->
      it "defines a method that returns a memoized relation given by the definition", ->
        class Comment extends Monarch.Record
          @extended(this)
          @columns(postId: 'integer', public: 'boolean')

        BlogPost.relatesTo 'comments', ->
          Comment.where(postId: this.id())

        BlogPost.relatesTo 'publicComments', ->
          Comment.where(postId: this.id(), public: true)

        post = BlogPost.created(id: 1)

        expect(post.comments()).toEqual(Comment.where({postId: 1}))
        expect(post.comments()).toBe(post.comments()) # memoized

        expect(post.comments()).not.toBe(post.publicComments())

    describe "@belongsTo(name, options)", ->
      it "sets up a belongs to relationship", ->
        expect(window.User).toBeUndefined()
        class Blog extends Monarch.Record
          @extended(this)
          @columns(userId: 'integer')

        expect(Blog.belongsTo('user')).toBe(Blog)

        class User extends Monarch.Record
          @extended(this)

        user = User.created(id: 1)
        blog = Blog.created(id: 1, userId: 1)
        expect(blog.user()).toBe(user)

      it "supports a 'className' option", ->
        class Comment extends Monarch.Record
          @extended(this)
          @columns(postId: 'integer')
          @belongsTo('post', className: 'BlogPost')

        post = BlogPost.created(id: 1)
        comment = Comment.created(id: 1, postId: 1)
        expect(comment.post()).toBe(post)

      it "supports a 'foreignKey' option", ->
        class Comment extends Monarch.Record
          @extended(this)
          @columns(blogPostId: 'integer')
          @belongsTo('post', className: 'BlogPost', foreignKey: 'blogPostId')

        post = BlogPost.created(id: 1)
        comment = Comment.created(id: 1, blogPostId: 1)
        expect(comment.post()).toBe(post)

    describe "@create(attrs)", ->
      [promise, onSuccessCallback] = []

      beforeEach ->
        BlogPost.columns
          title: 'string',
          body: 'string',
          blogId: 'integer'

        promise = BlogPost.create(title: "Testing", body: "1 2 3", blogId: 1)
        expect(Monarch.Repository.isPaused()).toBeTruthy()
        onSuccessCallback = jasmine.createSpy('onSuccessCallback')

      it "sends a create command to the server", ->
        expect(lastAjaxRequest.url).toBe('/blog-posts')
        expect(lastAjaxRequest.type).toBe('post')
        expect(lastAjaxRequest.data).toEqual(fieldValues: { title: "Testing", body: "1 2 3", blogId: 1 })

      describe "when Monarch.snakeCase is true", ->
        it "converts keys to snake case before sending them to the server", ->
          Monarch.snakeCase = true
          promise = BlogPost.create(title: "Testing", body: "1 2 3", blogId: 1)
          expect(lastAjaxRequest.data).toEqual(field_values: { title: "Testing", body: "1 2 3", blog_id: 1 })

      describe "when no field values are passed", ->
        it "does not send a fieldValues param to the server", ->
          BlogPost.create()
          expect(lastAjaxRequest.url).toBe('/blog-posts')
          expect(lastAjaxRequest.type).toBe('post')
          expect(lastAjaxRequest.data).toBeUndefined()

      describe "when the server responds to the create request successfully", ->
        it "assigns the remote fields with the attributes from the server, inserts it into its table, and triggers success on the promise", ->
          promise.onSuccess(onSuccessCallback)

          lastAjaxRequest.success(
            id: 23,
            title: "Testing +",
            body: "1 2 3 +",
            blogId: 2
          )

          expect(onSuccessCallback).toHaveBeenCalled()
          post = onSuccessCallback.mostRecentCall.args[0]
          expect(post instanceof Monarch.Record).toBeTruthy()
          expect(post.id()).toBe(23)
          expect(post.title()).toBe("Testing +")
          expect(post.body()).toBe("1 2 3 +")
          expect(post.blogId()).toBe(2)
          expect(BlogPost.contains(post)).toBeTruthy()
          expect(Monarch.Repository.isPaused()).toBeFalsy()

        describe "when Monarch.snakeCase is true", ->
          it "converts the fields returned from the server to camelCase", ->
            Monarch.snakeCase = true
            promise.onSuccess(onSuccessCallback)

            lastAjaxRequest.success(id: 23, blog_id: 33)
            expect(onSuccessCallback).toHaveBeenCalled()
            post = onSuccessCallback.mostRecentCall.args[0]
            expect(post.blogId()).toBe 33

      describe "when the server responds with validation errors", ->
        it "assigns validation errors on the record and marks it invalid", ->
          onInvalidCallback = jasmine.createSpy('onInvalidCallback')
          promise.onInvalid(onInvalidCallback)

          lastAjaxRequest.error
            status: 422,
            responseText: JSON.stringify({
              title: ["Error message 1", "Error message 2"],
              body: ["Error message 3"]
            })

          expect(onInvalidCallback).toHaveBeenCalled()
          post = onInvalidCallback.mostRecentCall.args[0]
          expect(post instanceof Monarch.Record).toBeTruthy()
          expect(post.isValid()).toBeFalsy()
          expect(post.errors.on('title')).toEqual(["Error message 1", "Error message 2"])
          expect(post.errors.on('body')).toEqual(["Error message 3"])
          expect(Monarch.Repository.isPaused()).toBeFalsy()

        describe "when Monarch.snakeCase is true", ->
          it "converts the fields names returned from the server to camelCase", ->
            Monarch.snakeCase = true
            onInvalidCallback = jasmine.createSpy('onInvalidCallback')
            promise.onInvalid(onInvalidCallback)

            lastAjaxRequest.error
              status: 422,
              responseText: JSON.stringify({
                blog_id: ["Error message 1", "Error message 2"],
              })

            expect(onInvalidCallback).toHaveBeenCalled()
            post = onInvalidCallback.mostRecentCall.args[0]
            expect(post.errors.on('blogId')).toEqual(["Error message 1", "Error message 2"])

  describe "instance methods", ->
    BlogPost = null

    beforeEach ->
      class BlogPost extends Monarch.Record
        @extended(this)
        @columns
          blogId: 'key'
          title: 'string'
          body: 'string'

    describe "constructor", ->
      it "builds fields for each of the table's columns", ->
        post = new BlogPost()
        expect(post.getField('title').column).toBe(BlogPost.getColumn('title'))
        expect(post.getField('body').column).toBe(BlogPost.getColumn('body'))

      it "assigns the record a provisional key and inserts it into its table, then calls afterInitialize", ->
        insertCallback = jasmine.createSpy('insertCallback')
        BlogPost.onInsert(insertCallback)
        spyOn(BlogPost.prototype, 'afterInitialize')

        post = new BlogPost()
        expect(post.id()).toBeLessThan(0)
        expect(insertCallback).toHaveBeenCalled()
        expect(insertCallback.arg(0)).toBe post
        expect(insertCallback.arg(1)).toBe 0
        expect(post.afterInitialize).toHaveBeenCalled()

    describe "#localUpdate(attributes)", ->
      it "updates the local field values and triggers an update event on the record's table", ->
        post = new BlogPost(id: 1, blogId: 1, title: "Alpha")
        updateCallback = jasmine.createSpy('updateCallback')
        BlogPost.onUpdate(updateCallback)

        post.localUpdate(blogId: 2, body: "Beta")
        expect(post.blogId()).toBe 2
        expect(post.title()).toBe "Alpha"
        expect(post.body()).toBe "Beta"

        expect(updateCallback).toHaveBeenCalled()
        expect(updateCallback.arg(0)).toBe post
        expect(updateCallback.arg(1)).toEqual
          blogId:
            newValue: 2
            oldValue: 1
            column: BlogPost.getColumn('blogId')
          body:
            newValue: "Beta"
            oldValue: undefined
            column: BlogPost.getColumn('body')

    describe "#save()", ->
      promise = null

      describe "when the record has already been created", ->
        [post, onSuccessCallback] = []
        beforeEach ->
          post = BlogPost.created(id: 1, blogId: 1, title: 'Title', body: 'Body')
          expect(post.isDirty()).toBeFalsy()
          onSuccessCallback = jasmine.createSpy('onSuccessCallback')

        describe "when the record is dirty", ->
          beforeEach ->
            post.localUpdate(blogId: 2, body: 'Body++')
            expect(post.isDirty()).toBeTruthy()
            promise = post.save()
            expect(post.isDirty()).toBeTruthy()
            expect(Monarch.Repository.isPaused()).toBeTruthy()

            promise.onSuccess(onSuccessCallback)

          it "sends the dirty fields to the server in a put to the record's url", ->
            expect(lastAjaxRequest.url).toBe('/blog-posts/1')
            expect(lastAjaxRequest.type).toBe('put')
            expect(lastAjaxRequest.data).toEqual(fieldValues: { blogId: 2, body : "Body++"})

          describe "when Monarch.snakeCase is true", ->
            it "sends snake-cased field names to the server", ->
              Monarch.snakeCase = true
              promise = post.save()
              expect(lastAjaxRequest.data).toEqual(field_values: { blog_id: 2, body : "Body++"})

          describe "when the server responds to the update successfully", ->
            it "updates the record with the attributes returned and triggers success on the promise with the record and a change set", ->
              onSuccessCallback = jasmine.createSpy('onSuccessCallback')
              promise.onSuccess(onSuccessCallback)

              lastAjaxRequest.success
                blogId: 2,
                body: "Body+++"

              expect(onSuccessCallback).toHaveBeenCalled()

              expect(onSuccessCallback.mostRecentCall.args[0]).toBe(post)
              expect(post instanceof Monarch.Record).toBeTruthy()
              expect(post.blogId()).toBe(2)
              expect(post.body()).toBe("Body+++")
              expect(post.isDirty()).toBeFalsy()

              expect(onSuccessCallback.mostRecentCall.args[1]).toEqual
                body:
                  oldValue: "Body++"
                  newValue: "Body+++"
                  column: BlogPost.getColumn('body')

              expect(Monarch.Repository.isPaused()).toBeFalsy()

            describe "when Monarch.snakeCase is true", ->
              it "converts keys in the response to camelCase", ->
                Monarch.snakeCase = true

                lastAjaxRequest.success
                  blog_id: 3,
                  body: "Body+++"

                expect(onSuccessCallback).toHaveBeenCalled()

                expect(onSuccessCallback.mostRecentCall.args[0]).toBe(post)
                expect(post instanceof Monarch.Record).toBeTruthy()
                expect(post.blogId()).toBe(3)
                expect(post.body()).toBe("Body+++")
                expect(post.isDirty()).toBeFalsy()

            it "does not proceed with the creation if beforeSave returns 'false'", ->
              $.ajax.reset()
              post = BlogPost.created(id: 1, title: "Alpha", body: "Bravo")
              spyOn(post, 'beforeSave').andReturn(false)

              post.save()

              expect(post.beforeSave).toHaveBeenCalled()
              expect($.ajax).not.toHaveBeenCalled()

          describe "when the server responds with validation errors", ->
            onInvalidCallback = null

            beforeEach ->
              onInvalidCallback = jasmine.createSpy('onInvalidCallback')
              promise.onInvalid(onInvalidCallback)

            it "assigns validation errors on the record and marks it invalid", ->
              lastAjaxRequest.error
                status: 422,
                responseText: JSON.stringify
                  title: ["Error message 1", "Error message 2"],
                  body: ["Error message 3"]

              expect(onInvalidCallback).toHaveBeenCalled()
              post = onInvalidCallback.mostRecentCall.args[0]
              expect(post instanceof Monarch.Record).toBeTruthy()
              expect(post.isValid()).toBeFalsy()
              expect(post.errors.on('title')).toEqual(["Error message 1", "Error message 2"])
              expect(post.errors.on('body')).toEqual(["Error message 3"])

              expect(Monarch.Repository.isPaused()).toBeFalsy()

            describe "when Monarch.snakeCase is true", ->
              it "converts validation errors to camel case", ->
                Monarch.snakeCase = true

                lastAjaxRequest.error
                  status: 422,
                  responseText: JSON.stringify
                    blog_id: ["Error message 1", "Error message 2"]

                expect(onInvalidCallback).toHaveBeenCalled()
                post = onInvalidCallback.mostRecentCall.args[0]
                expect(post.isValid()).toBeFalsy()
                expect(post.errors.on('blogId')).toEqual(["Error message 1", "Error message 2"])

        describe "when the record is clean", ->
          beforeEach ->
            expect(post.isDirty()).toBeFalsy()

          it "calls the beforeSave hook, but does not send a request to the server", ->
            spyOn(post, 'beforeSave')
            post.save().onSuccess(onSuccessCallback)

            expect(post.beforeSave).toHaveBeenCalled()
            expect(lastAjaxRequest).toBeUndefined()
            expect(onSuccessCallback).toHaveBeenCalledWith(post)

      describe "when the record has not yet been created", ->
        post = null

        beforeEach ->
          post = new BlogPost({title: "Bad Title", body: "Bad Body"})
          post.save()

          lastAjaxRequest.error
            status: 422,
            responseText: JSON.stringify
              title: ["Error message 1"],
              body: ["Error message 2"]

          expect(post.isValid()).toBeFalsy()

          post.localUpdate(title: "Good Title", body: "Good Body")
          promise = post.save()

        it "sends a create command to the server", ->
          expect(lastAjaxRequest.url).toBe('/blog-posts')
          expect(lastAjaxRequest.type).toBe('post')
          expect(lastAjaxRequest.data).toEqual(fieldValues: { title: "Good Title", body: "Good Body" })

        describe "if the server responds successfully", ->
          it "marks the record as persisted and clears validation errors", ->
            onSuccessCallback = jasmine.createSpy('onSuccessCallback')
            promise.onSuccess(onSuccessCallback)

            lastAjaxRequest.success
              id: 23,
              title: "Good Title+",
              body: "Good Body+"

            expect(onSuccessCallback).toHaveBeenCalled()
            post = onSuccessCallback.mostRecentCall.args[0]
            expect(post instanceof Monarch.Record).toBeTruthy()
            expect(post.id()).toBe(23)
            expect(post.title()).toBe("Good Title+")
            expect(post.body()).toBe("Good Body+")
            expect(BlogPost.contains(post)).toBeTruthy()
            expect(post.isValid()).toBeTruthy()

          it "updates any records that depend on the record's provisional id", ->
            class Comment extends Monarch.Record
              @extended(this)
              @columns blogPostId: 'key', body: 'string'
            BlogPost.hasMany 'comments'

            expect(ajaxRequests.length).toBe 2
            comment = post.comments().build(body: "I like your post")
            comment.save()
            expect(comment.blogPostId()).toBeLessThan(0)
            expect(ajaxRequests.length).toBe 2

            lastAjaxRequest.success
              id: 23,
              title: "Good Title+",
              body: "Good Body+"

            expect(comment.blogPostId()).toBe(23)
            expect(ajaxRequests.length).toBe 3

        describe "create hooks", ->
          it "does not proceed with the creation if beforeSave returns 'false'", ->
            $.ajax.reset()
            post = new BlogPost(title: "Alpha", body: "Bravo")
            spyOn(post, 'beforeSave').andReturn(false)

            post.save()

            expect(post.beforeSave).toHaveBeenCalled()
            expect($.ajax).not.toHaveBeenCalled()

    describe "#updated", ->
      it "only triggers update callbacks if a change was made", ->
        post = BlogPost.created(id: 1, title: "Title")

        updateCallback = jasmine.createSpy("updateCallback")
        BlogPost.onUpdate(updateCallback)

        post.updated(title: "Title")

        expect(updateCallback).not.toHaveBeenCalled()

    describe "#destroy()", ->
      post = null

      beforeEach ->
        post = BlogPost.created(id: 44, title: "Title")

      it "sends a delete request to the record's url, then removes it from the repository", ->
        promise = post.destroy()
        expect(BlogPost.contains(post)).toBeTruthy(); # waits for server

        expect(lastAjaxRequest.url).toBe('/blog-posts/44')
        expect(lastAjaxRequest.type).toBe('delete')

        expect(Monarch.Repository.isPaused()).toBeTruthy()

        onSuccessCallback = jasmine.createSpy('onSuccessCallback')
        promise.onSuccess(onSuccessCallback)

        lastAjaxRequest.success()

        expect(onSuccessCallback).toHaveBeenCalled()
        expect(BlogPost.contains(post)).toBeFalsy()
        expect(Monarch.Repository.isPaused()).toBeFalsy()

      describe "destroy hooks", ->
        it "invokes beforeDestroy and afterDestroy hooks", ->
          spyOn(post, 'beforeDestroy')
          spyOn(post, 'afterDestroy')

          post.destroy()

          expect(post.beforeDestroy).toHaveBeenCalled()
          expect(post.afterDestroy).not.toHaveBeenCalled()

          lastAjaxRequest.success()

          expect(post.afterDestroy).toHaveBeenCalled()

        it "does not proceed with the destroy if the beforeDestroy hook returns 'false'", ->
          $.ajax.reset()
          post = BlogPost.created(id: 44, title: "Title")
          spyOn(post, 'beforeDestroy').andReturn(false)

          post.destroy()

          expect($.ajax).not.toHaveBeenCalled()

    describe "#onUpdate(callback, context)", ->
      it "registers the given callback to be triggered when the record is updated", ->
        post = BlogPost.created(id: 1, title: "Title")
        updateCallback = jasmine.createSpy('updateCallback')
        context = {}
        post.onUpdate(updateCallback, context)

        post.updated(title: "Title Prime")

        expect(updateCallback).toHaveBeenCalled()
        expect(updateCallback.arg(0)).toEqual
          title:
            oldValue: 'Title'
            newValue: 'Title Prime'
            column: BlogPost.getColumn('title')

    describe "#onDestroy", ->
      it "registers the given callback to be triggered when the record is destroyed", ->
        post = BlogPost.created(id: 1, title: "Title")
        destroyCallback = jasmine.createSpy('destroyCallback')
        context = {}
        post.onDestroy(destroyCallback, context)

        post.destroyed()

        expect(destroyCallback).toHaveBeenCalled()

    describe "#signal(fieldName)", ->
      it "returns a signal based on the value of the field that responds to it changing", ->
        post = BlogPost.created(id: 1, title: "Title")
        signal = post.signal 'title', (title) ->
          title + " Prime"
        onChangeCallback = jasmine.createSpy('onChangeCallback')

        expect(signal.getValue()).toBe("Title Prime")
        signal.onChange(onChangeCallback)
        post.updated(title: "Foo")
        expect(onChangeCallback).toHaveBeenCalledWith("Foo Prime", "Title Prime")

    describe "#getField(name)", ->
      it "accepts qualified and unqualified names, ensuring the qualifier matches the table name", ->
        post = BlogPost.created(id: 1, title: "Title")

        expect(post.getField('title').getValue()).toBe("Title")
        expect(post.getField('BlogPost.title').getValue()).toBe("Title")
        expect(post.getField('FooBar.title')).toBeUndefined()

    describe "field accessors", ->
      it "triggers update events when field values are changed via individual accessors", ->
        post = BlogPost.created(id: 1, title: "Title")
        tableUpdateCallback = jasmine.createSpy('tableUpdateCallback')
        recordUpdateCallback = jasmine.createSpy('recordUpdateCallback')

        BlogPost.onUpdate(tableUpdateCallback)
        post.onUpdate(recordUpdateCallback)

        post.title("Title Prime")

        expect(tableUpdateCallback).toHaveBeenCalled()
        expect(tableUpdateCallback.arg(0)).toBe post
        expect(tableUpdateCallback.arg(1)).toEqual
          title:
            oldValue: 'Title'
            newValue: 'Title Prime'
            column: BlogPost.getColumn('title')

        expect(recordUpdateCallback).toHaveBeenCalled()
        expect(recordUpdateCallback.arg(0)).toEqual
          title:
            oldValue: 'Title'
            newValue: 'Title Prime'
            column: BlogPost.getColumn('title')

    describe "type conversion", ->
      it "converts integers to Date objects for fields with the type of 'datetime'", ->
        BlogPost.column('createdAt', 'datetime')
        post = BlogPost.created(id: 1, blogId: 1, createdAt: 12345)
        expect(post.createdAt().constructor).toBe(Date)
        expect(post.createdAt().getTime()).toBe(12345)

    describe "#wireRepresentation", ->
      post = null

      beforeEach ->
        BlogPost.columns
          createdAt: 'datetime'
          title: 'string'
          body: 'string'

        BlogPost.syntheticColumn 'fooTitle', ->
          this.signal 'title', (title) ->
            title + " Foo"

        post = BlogPost.created(id: 1, blogId: 1, title: 'Title', body: 'Body', createdAt: 12345)

      describe "when called with no arguments", ->
        it "only includes dirty fields", ->
          post.title('Title Prime')
          post.body('Body Prime')

          expect(post.getField('createdAt').isDirty()).toBeFalsy()
          expect(post.wireRepresentation()).toEqual
            title: 'Title Prime'
            body: 'Body Prime'

      describe "when called with true", ->
        it "includes all fields", ->
          post.title('Title Prime')
          expect(post.wireRepresentation(true)).toEqual
            id: 1
            blogId: 1
            title: 'Title Prime'
            body: 'Body'
            createdAt: 12345

      it "converts Date objects to epoch millisecond integers", ->
        expect(post.wireRepresentation(true).createdAt).toBe(12345)
        post.createdAt(null)
        expect(post.wireRepresentation(true).createdAt).toBeNull()

    describe "#isEqual", ->
      post1 = null

      beforeEach ->
        post1 = BlogPost.created(id: 1, title: "on equality", blogId: 10)
        BlogPost.clear()

      it "returns false for records with different ids", ->
        post2 = BlogPost.created(id: 2, title: "on equality", blogId: 10)
        expect(post1).not.toEqual(post2)

      it "returns false for records of different classes", ->
        class BlogReview extends Monarch.Record
          @extended(this)
          @columns
            blogId: 'integer'
            title: 'string'
            body: 'string'

        review1 = BlogReview.created(id: 1, title: "on equality", blogId: 10)
        expect(post1).not.toEqual(review1)

      it "returns true for records with the same id", ->
        otherPost1 = BlogPost.created(id: 1)
        expect(post1).toEqual(otherPost1)

    describe "#fetch", ->
      it "fetches the record from the server", ->
        post1 = BlogPost.created(id: 1, title: "on equality", blogId: 10)
        post1.fetch()

        expect($.ajax).toHaveBeenCalled()
        expect(lastAjaxRequest.type).toBe('get')
        relation = JSON.parse(lastAjaxRequest.data.relations)[0]

        expect(relation.type).toBe('Selection')
        expect(relation.operand.name).toBe('blog-posts')
        expect(relation.predicate.leftOperand.name).toBe('id')
        expect(relation.predicate.rightOperand.value).toBe(1)

describe "Monarch.Record", ->
  describe "class methods", ->
    BlogPost = null

    beforeEach ->
      class BlogPost extends Monarch.Record
        @inherited(this)

    describe "@inherited(subclass)", ->
      it "associates subclasses with a table in the repository", ->
        expect(BlogPost.name).toBe('BlogPost')
        expect(BlogPost.table instanceof Monarch.Relations.Table).toBeTruthy()
        expect(BlogPost.table.name).toBe('BlogPost')
        expect(BlogPost.table.remoteName).toBe('blog_posts')
        expect(BlogPost.table).toEqual(Monarch.Repository.tables.BlogPost)

      it "automatically defines an integer-typed id column", ->
        expect(BlogPost.table.getColumn('id').type).toBe('integer')

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
        lastAjaxRequest.success(title: "Bar")
        expect(onSuccessCallback).toHaveBeenCalled()
        expect(onSuccessCallback.mostRecentCall.args[1]).toEqual(
          title:
            newValue: "Bar"
            oldValue: "Foo"
            column: BlogPost.getColumn('title')

          titlePrime:
            newValue: "Bar Prime"
            oldValue: "Foo Prime"
            column: BlogPost.getColumn('titlePrime')
        )

    describe "@hasMany", ->
      it "defines a hasMany relation", ->
        expect(BlogPost.hasMany('comments')).toBe(BlogPost)

        class Comment extends Monarch.Record
          @inherited(this)
          @columns(blogPostId: 'integer')

        post = BlogPost.created(id: 1)
        expect(post.comments()).toEqual(Comment.where({blogPostId: 1}))

      it "supports a 'className' option", ->
        class PostComment extends Monarch.Record
          @inherited(this)
          @columns(blogPostId: 'integer')

        BlogPost.hasMany('comments', className: 'PostComment')

        post = BlogPost.created(id: 1)
        expect(post.comments()).toEqual(PostComment.where(blogPostId: 1))

      it "supports a 'foreignKey' option", ->
        class Comment extends Monarch.Record
          @inherited(this)
          @columns(postId: 'integer')

        BlogPost.hasMany('comments', foreignKey: 'postId')

        post = BlogPost.created(id: 1)
        expect(post.comments()).toEqual(Comment.where(postId: 1))

      it "supports an 'orderBy' option", ->
        class Comment extends Monarch.Record
          @inherited(this)
          @columns(blogPostId: 'integer', body: 'string', createdAt: 'datetime')

        BlogPost.hasMany('comments', orderBy: 'body desc')
        post1 = BlogPost.created(id: 1)
        expect(post1.comments()).toEqual(Comment.where({blogPostId: 1}).orderBy('body desc'))

        BlogPost.hasMany('comments', orderBy: ['body desc', 'createdAt'])
        post2 = BlogPost.created(id: 2)
        expect(post2.comments()).toEqual(Comment.where({blogPostId: 2}).orderBy('body desc', 'createdAt'))

      it "supports a 'conditions' option", ->
        class Comment extends Monarch.Record
          @inherited(this)
          @columns(blogPostId: 'integer', public: 'boolean', score: 'integer')

        BlogPost.hasMany('comments', conditions: { public: true, 'score >': 3 })
        post = BlogPost.created(id: 1)
        # conditions are turned into an 'and' tree, and may be order sensitive. chrome seems to respect lexical order
        expect(post.comments()).toEqual(Comment.where({ public: true, 'score >': 3, blogPostId: 1 }))

      it "supports a 'through' option", ->
        class Blog extends Monarch.Record
          @inherited(this)
          @hasMany('posts', className: 'BlogPost')
          @hasMany('comments', through: 'posts')

        class Comment extends Monarch.Record
          @inherited(this)
          @columns(blogPostId: 'integer')

        BlogPost.columns(blogId: 'integer')

        blog = Blog.created(id: 1)
        expect(blog.comments()).toEqual(blog.posts().joinThrough(Comment))

    describe "@relatesTo(name, definition)", ->
      it "defines a method that returns a memoized relation given by the definition", ->
        class Comment extends Monarch.Record
          @inherited(this)
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
          @inherited(this)
          @columns(userId: 'integer')

        expect(Blog.belongsTo('user')).toBe(Blog)

        class User extends Monarch.Record
          @inherited(this)

        user = User.created(id: 1)
        blog = Blog.created(id: 1, userId: 1)
        expect(blog.user()).toBe(user)

      it "supports a 'className' option", ->
        class Comment extends Monarch.Record
          @inherited(this)
          @columns(postId: 'integer')
          @belongsTo('post', className: 'BlogPost')

        post = BlogPost.created(id: 1)
        comment = Comment.created(id: 1, postId: 1)
        expect(comment.post()).toBe(post)

      it "supports a 'foreignKey' option", ->
        class Comment extends Monarch.Record
          @inherited(this)
          @columns(blogPostId: 'integer')
          @belongsTo('post', className: 'BlogPost', foreignKey: 'blogPostId')

        post = BlogPost.created(id: 1)
        comment = Comment.created(id: 1, blogPostId: 1)
        expect(comment.post()).toBe(post)

    describe "@create(attrs)", ->
      promise = null

      beforeEach ->
        BlogPost.columns
          title: 'string',
          body: 'string',
          blogId: 'integer'

        promise = BlogPost.create(title: "Testing", body: "1 2 3", blogId: 1)
        expect(Monarch.Repository.isPaused()).toBeTruthy()

      it "sends a create command to the server", ->
        expect(lastAjaxRequest.url).toBe('/sandbox/blog_posts')
        expect(lastAjaxRequest.type).toBe('post')
        expect(lastAjaxRequest.data).toEqual(field_values: { title: "Testing", body: "1 2 3", blog_id: 1 })

      describe "when no field values are passed", ->
        it "does not send a field_values param to the server", ->
          BlogPost.create()
          expect(lastAjaxRequest.url).toBe('/sandbox/blog_posts')
          expect(lastAjaxRequest.type).toBe('post')
          expect(lastAjaxRequest.data).toBeUndefined()

      describe "when the server creates the record successfully", ->
        it "assigns the remote fields with the attributes from the server, inserts it into its table, and triggers success on the promise", ->
          onSuccessCallback = jasmine.createSpy('onSuccessCallback')
          promise.onSuccess(onSuccessCallback)

          lastAjaxRequest.success(
            id: 23,
            title: "Testing +",
            body: "1 2 3 +",
            blog_id: 1
          )

          expect(onSuccessCallback).toHaveBeenCalled()
          post = onSuccessCallback.mostRecentCall.args[0]
          expect(post instanceof Monarch.Record).toBeTruthy()
          expect(post.id()).toBe(23)
          # expect(post.title()).toBe("Testing +")
          # expect(post.body()).toBe("1 2 3 +")
          # expect(post.blogId()).toBe(1)
          # expect(BlogPost.contains(post)).toBeTruthy()
          # expect(Monarch.Repository.isPaused()).toBeFalsy()

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

  describe "instance methods", ->
    BlogPost = null

    beforeEach ->
      class BlogPost extends Monarch.Record
        @inherited(this)
        @columns
          blogId: 'integer',
          title: 'string',
          body: 'string'

    describe "#initialize()", ->
      it "builds fields for each of the table's columns", ->
        post = new BlogPost()
        expect(post.getField('title').column).toBe(BlogPost.getColumn('title'))
        expect(post.getField('body').column).toBe(BlogPost.getColumn('body'))

      it "calls afterInitialize", ->
        spyOn(BlogPost.prototype, 'afterInitialize')
        post = new BlogPost()
        expect(post.afterInitialize).toHaveBeenCalled()

    describe "#save()", ->
      promise = null

      describe "when the record has already been created", ->
        post = null
        beforeEach ->
          post = BlogPost.created(id: 1, blogId: 1, title: 'Title', body: 'Body')
          expect(post.isDirty()).toBeFalsy()

          post.localUpdate(blogId: 2, body: 'Body++')
          expect(post.isDirty()).toBeTruthy()
          promise = post.save()
          expect(post.isDirty()).toBeTruthy()
          expect(Monarch.Repository.isPaused()).toBeTruthy()

        it "sends the dirty fields to the server in a put to the record's url", ->
          expect(lastAjaxRequest.url).toBe('/sandbox/blog_posts/1')
          expect(lastAjaxRequest.type).toBe('put')
          expect(lastAjaxRequest.data).toEqual(field_values: { blog_id: 2,body : "Body++"})

        describe "when the server updates the record successfully", ->
          it "updates the record with the attributes returned and triggers success on the promise with the record and a change set", ->
            onSuccessCallback = jasmine.createSpy('onSuccessCallback')
            promise.onSuccess(onSuccessCallback)

            lastAjaxRequest.success
              blog_id: 2,
              body: "Body+++"

            expect(onSuccessCallback).toHaveBeenCalled()

            expect(onSuccessCallback.mostRecentCall.args[0]).toBe(post)
            expect(post instanceof Monarch.Record).toBeTruthy()
            expect(post.blogId()).toBe(2)
            expect(post.body()).toBe("Body+++")
            expect(post.isDirty()).toBeFalsy()

            expect(onSuccessCallback.mostRecentCall.args[1]).toEqual
              blogId:
                oldValue: 1
                newValue: 2
                column: BlogPost.getColumn('blogId')
              body:
                oldValue: "Body"
                newValue: "Body+++"
                column: BlogPost.getColumn('body')

            expect(Monarch.Repository.isPaused()).toBeFalsy()

        describe "update hooks", ->
          it "invokes beforeUpdate and afterUpdate hooks if present on the record", ->
            post = BlogPost.created(id: 1, title: "Alpha", body: "Bravo")
            spyOn(post, 'beforeUpdate')
            spyOn(post, 'afterUpdate')

            post.save()

            expect(post.beforeUpdate).toHaveBeenCalled()
            expect(post.afterUpdate).not.toHaveBeenCalled()

            lastAjaxRequest.success
              id: 23,
              title: "Good Title+",
              body: "Good Body+"

            expect(post.afterUpdate).toHaveBeenCalled()

          it "does not proceed with the creation if beforeCreate returns 'false'", ->
            $.ajax.reset()
            post = BlogPost.created(id: 1, title: "Alpha", body: "Bravo")
            spyOn(post, 'beforeUpdate').andReturn(false)

            post.save()

            expect(post.beforeUpdate).toHaveBeenCalled()
            expect($.ajax).not.toHaveBeenCalled()

        describe "when the server responds with validation errors", ->
          it "assigns validation errors on the record and marks it invalid", ->
            onInvalidCallback = jasmine.createSpy('onInvalidCallback')
            promise.onInvalid(onInvalidCallback)

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

      describe "when the record has not yet been created", ->
        beforeEach ->
          record = null
          BlogPost.create({title: "Bad Title", body: "Bad Body"}).onInvalid (r) ->
            record = r

          lastAjaxRequest.error
            status: 422,
            responseText: JSON.stringify
              title: ["Error message 1"],
              body: ["Error message 2"]

          expect(record.isValid()).toBeFalsy()

          record.localUpdate(title: "Good Title", body: "Good Body")
          promise = record.save()

        it "sends a create command to the server", ->
          expect(lastAjaxRequest.url).toBe('/sandbox/blog_posts')
          expect(lastAjaxRequest.type).toBe('post')
          expect(lastAjaxRequest.data).toEqual(field_values: { title: "Good Title", body: "Good Body" })

        describe "if the server responds successfully", ->
          it "inserts the record and clears validation errors", ->
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

        describe "create hooks", ->
          it "invokes beforeCreate and afterCreate hooks if present on the record", ->
            post = new BlogPost(title: "Alpha", body: "Bravo")
            spyOn(post, 'beforeCreate')
            spyOn(post, 'afterCreate')

            post.save()

            expect(post.beforeCreate).toHaveBeenCalled()
            expect(post.afterCreate).not.toHaveBeenCalled()

            lastAjaxRequest.success
              id: 23,
              title: "Good Title+",
              body: "Good Body+"

            expect(post.afterCreate).toHaveBeenCalled()

          it "does not proceed with the creation if beforeCreate returns 'false'", ->
            $.ajax.reset()
            post = new BlogPost(title: "Alpha", body: "Bravo")
            spyOn(post, 'beforeCreate').andReturn(false)

            post.save()

            expect(post.beforeCreate).toHaveBeenCalled()
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

        expect(lastAjaxRequest.url).toBe('/sandbox/blog_posts/44')
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

    describe "field access", ->
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
            blog_id: 1
            title: 'Title Prime'
            body: 'Body'
            created_at: 12345

      it "converts Date objects to epoch millisecond integers", ->
        expect(post.wireRepresentation(true).created_at).toBe(12345)
        post.createdAt(null)
        expect(post.wireRepresentation(true).created_at).toBeNull()

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
          @inherited(this)
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

        expect(relation.type).toBe('selection')
        expect(relation.operand.name).toBe('blog_posts')
        expect(relation.predicate.left_operand.name).toBe('id')
        expect(relation.predicate.right_operand.value).toBe(1)

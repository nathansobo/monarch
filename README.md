# Monarch

Monarch is a relational modeling framework for client-centric web applications.
It's superficially similar to Backbone.js, but it uses the relational algebra as
a declarative, compositional language for querying data and subscribing to
events. Monarch is written in CoffeeScript, but can also be used from
JavaScript.


## Defining Model Classes

Monarch associates model constructors with tables in an in-memory relational
database. On the surface, the API resembles ActiveRecord.

To define a record class in CoffeeScript, create a subclass of `Monarch.Record`.

```coffeescript
class Blog extends Monarch.Record
  @extended(this)

  @columns
    userId: 'integer'
    title: 'string'
    createdAt: 'datetime'

  @belongsTo 'user'
  @hasMany 'posts'
  @hasMany 'postComments', through: 'posts', className: 'Comment'
```

Until CoffeeScript offers an automatic `@extended` hook, you'll need to
call `@extended` manually at the top of the class body. Next, call `@columns`
with a hash of field-name/type pairs, and optionally call `@hasMany` and
`@belongsTo` association methods. More on those later...

### In JavaScript

```javascript
function() Blog {}

Monarch(Blog, {
  userId: 'integer',
  title: 'string',
  createdAt: 'datetime'
})
  .belongsTo('user')
  .hasMany('posts')
  .hasMany('postComments', { through: 'posts', className: 'Comment' });
```

To define a record class in JavaScript, first create a constructor, then pass it
to the top-level `Monarch` function along with a hash of column definitions. It
will automatically be setup as a subclass of `Monarch.Record`. The `Monarch`
function returns your constructor, so other class methods can be called in a
method-chaining style. Unless otherwise noted, examples will be shown in
CoffeeScript from here on out.

## Loading Data

### Bulk Loading

Once you've defined some record classes, you load data into their associated
tables in the repository by calling `Monarch.Repository.update` with a hash of
records.

```coffeescript
Monarch.Repository.update(
  Blog:
    1: { userId: 1, title: "Blog I Never Update", createdAt: 1332433460811 }
    2: { userId: 2, title: "Blog That No One Reads", createdAt: 1332433434561 }
  BlogPost:
    1: { blogId: 1, title: "First Post", body: "More to come!" }
    2: { blogId: 2, title: "I'm Lonely'", body: "Please read my LiveJournal." }
    3: { blogId: 2, title: "Comments", body: "No one commented on my last post." }
)
```

As you can see above, the hash can contain records for multiple tables,
structured in a (table name, record id, field values) format. If a record for a
given (table name, record id) pair already exists, it will be updated with the
provide field values. Otherwise a new record will be created with those field
values.

### Updating With Operations

You can also call `Monarch.Repository.update` with an array of `create`,
`update`, and `destroy` operations. This is useful, for example, when you are
handling real-time events delivered via a web socket. Operations are performed
in the order in which they appear in the array.

```coffeescript
Monarch.Repository.update([
  ['create', 'BlogPost', { id: 3, blog_id: 2, title: "I Love Star Wars!" }],
  ['update', 'BlogPost', 2, { title: "I Can't Decide on a Title'" }],
  ['destroy', 'BlogPost', 2]
])
```

* Create operation arrays start with `create`, then have a record class name and
  a hash of field values.

* Update operation arrays start with `update`, then have a record class name, a
  record id, and a hash of field values.

* Destroy operation arrays start with `destroy`, then have a record class name
  and a record id.

### jQuery Ajax Data Types

Monarch adds 4 custom jQuery ajax data types that help you load data from your
API endpoints. If you use `jQuery.ajax` to perform a GET request and specify a
data type of `records`, you can return a JSON hash of (table name, id, field
values) and Monarch will automatically update the repository with the response's
data.

```coffeescript
jQuery.ajax(url: '/blog-posts', dataType: 'records')
```
The following data types are supported:

* `records`: Assumes the response is a JSON hash of (table name, record id,
  field values) and automatically updates the repository with it.

* `data+records`: Assumes the response is a JSON hash with a `data` key and a
  `records` key. It updates the repository with the records and passes the
  `data` as JSON to your success callback.

* `records!`: Just like `records`, but clears existing data from the repository
  before updating it.

* `data+records!`: Just like `data+records`, but clears existing data from the
  repository before updating it.


## Working With Queries

Once you've loaded some data into the repository, you can query it with standard
relational operators. For example, a query to find all posts of public blogs
with more than five comments would be written as follows:

```coffeescript
Blog.where(public: true).join(Post.where('commentCount >': 5))
```

Every Monarch query is defined in terms of objects called relations. You can
think of a relation as a composable, object-oriented representation of a SQL
query. You can also think of a relation as a set of records. More precisely,
it's a declarative recipe for constructing a set of records based on the current
contents of the local repository.

### Accessing Records in a Relation

To retrieve a relation's records, call its `all` method. You can also iterate
over every record in the relation using `each` and `map`. For example:

```coffeescript
# iterate over posts in blog 42
Post.where(blogId: 42).each (post) ->
  console.log(post.title())
```

To retrieve a single record in a relation, use the `find` method.

```coffeescript
# Simple case: Call find on a record class with an id
post = Post.find(22)

# Call on a relation
post = Post.where(blogId: 42).find(22)

# Call find with a a predicate
post = Post.find(title: "The Relational Model")
```

### Subscribing to a Relation

One of Monarch's most powerful features is the ability to subscribe to changes
on any relation using the `onInsert`, `onUpdate` and `onRemove` methods. Using
these methods, you can describe a set of objects declaratively and then be
informed whenever some operation on the repository changes the contents of that
set.

```coffeescript
blogComments = Post.where(blogId: 5).joinThrough(Comment)

blogComments.onInsert (comment) ->
  console.log "There's a new comment on your blog by #{comment.user().fullName()}"
  console.log comment.body()

blogComments.onUpdate (comment, changeset) ->
  if changeset.body
    console.log "A comment by #{comment.user().fullName()} was updated:"
    console.log "Old body: #{changset.body.oldValue}"
    console.log "New body: #{changset.body.newValue}"

blogComments.onRemove (comment) ->
  console.log "A comment by #{comment.user().fullName()} was removed:"
  console.log comment.body()
```

Insert and remove callbacks are called with the inserted / removed record.
Update callbacks are passed an additional changeset hash, which includes a
sub-hash for every changed field containing its `oldValue` and `newValue`.

Event callbacks are also passed indices indicating the record's location in the
relation. See the [order by](#order-by) operation for details.

## Building Relations (i.e. Writing Queries)

Tables are the most primitive relations. You compose them into more complex
relations by applying relational operators, which are available as methods on
every relation.

### Selection (Where)

As you've seen in earlier examples, you filter the contents of any relation by
calling the `where` method with a hash of key-value pairs representing
predicates.

```coffeescript
popularAuthors = User.where(privacy: 'public', 'reputation >=': 500)

# Equivalent SQL:
# select * from users where privacy = 'public' and reputation >= 500;
```

You can express standard inequality operations by following the
column name with the operator in the hash key, per the above example. If the
hash contains multiple key-value pairs, the predicates they represent are
implicitly anded together.

### Inner Joins

Join one relation to another by calling the `join` method with the target
relation and a hash representing the predicate on which to join.

```coffeescript
# Note: Composing with the popularAuthors relation, defined above
popularAuthorsAndBlogs = popularAuthors.join(Blog, ownerId: 'Blog.id')

# Equivalent SQL:
# select *
# from users
#   inner join blogs on blogs.owner_id = users.id
# where users.privacy = 'public' and users.reputation >= 500
```

If one table references the other by name in its foreign-key, Monarch will infer
the join predicate. For example, if the Post table has a `blogId` column, then
you could write `Blog.join(Post)` without supplying `postId: 'Blog.id'` as a
second argument.

Joins return `CompositeTuples` instead of individual records in their results,
which combine two or more records into a single object. You can pull individual
field values or entire records out of composite tuples using the `getFieldValue`
or `getRecord` methods.

```coffeescript
popularAuthorsAndBlogs.each (tuple) ->
  name = tuple.getFieldValue('User.fullName')
  blogRecord = tuple.getRecord('Blog')
  console.log "#{blogRecord.title()} by {name} is a popular choice."
```

More often, you'll want to work with records from a single table of the join, by
applying the `project` operator, which we discuss next...

### Projection

When you join tables in SQL, you often include only a subset of the columns
available in the join by modifying your `select` clause. For example, if you
were selecting all a users blog posts, you would write:

```sql
select posts.* from blogs, posts where posts.blog_id = blogs.id...
```

In relational algebra, the `select posts.*` portion of this query is an
operation called *projection*. In Monarch, you perform projection by calling the
`project` method on any relation. Whereas raw joins return composite tuples as
their result type, projected joins return return individual records, making them
easier to work with in many cases.

```coffeescript
# Note: Composing with the popularAuthorsAndBlogs relation, defined above
popularPosts = popularAuthorsAndBlogs.join(Post).project(Post)

# Equivalent SQL:
# select posts.*
# from users
#   inner join blogs on blogs.owner_id = users.id
#   inner join posts on posts.blog_id = blogs.id
# where users.privacy = 'public' and users.reputation >= 500

console.log "Read this: " + popularPosts.first().body()
```

### Join-Through

Because `join` operations are so often composed with `project` operations,
Monarch offers the `joinThrough` method as a convenient shorthand. Using this
method, the query from the projection example above could be shortened to:

```coffeescript
popularPosts = popularAuthorsAndBlogs.joinThrough(Post)
```

If the join predicate can't be inferred, you can still pass it as a second
argument:

```coffeescript
popularBlogs = popularAuthors.joinThrough(Blog, ownerId: 'User.id')
```

### Order By

You can order a relation by one or more columns with the `orderBy` operator.

```coffeescript
# Note: Composing with the popularAuthors relation, defined above
rankedAuthors = popularAuthors.orderBy('popularity desc', 'fullName')
```

Now iterations over your relation with `each`, `map`, etcetera respect your
specified ordering. In addition, events that are triggered on your relation
include indices telling you where the event's record presides in your ordering.

```coffeescript
rankedAuthors.onInsert (user, index) ->
  console.log "#{user.fullName()} entered the ranking at position #{index}"

rankedAuthors.onUpdate (user, changeset, newIndex, oldIndex) ->
  console.log "#{user.fullName()} moved to ranking #{newIndex} from #{oldIndex}"
```

By default, all relations are ordered ascending by the `id` column. You can
change the default ordering of an entire table by calling the `defaultOrderBy`
class method on a record class.

```coffeescript
# order users by popularity in every relation
User.defaultOrderBy 'popularity desc'
```

Monarch uses a probalistic, ordered data-structure called an indexed skip-list
under the covers to keep efficient track of record indices.

### Limit and Offset

If you want to limit the size of a relation, use the `limit` method:

```coffeescript
top5Authors = rankedAuthors.limit(5)
```

If you want to change the relation's starting point, use the `offset` method:

```coffeescript
runnersUp = rankedAuthors.offset(5).limit(10)
```

You can also call `limit` with an optional second offset argument:

```coffeescript
runnersUp = rankedAuthors.limit(10, 5) # limit 10, offset 5
```

### Union

Use `union` to combine the contents of two relations.

```coffeescript
authorsOfInterest = top5Authors.union(followedAuthors)
```

### Difference

Use `difference` to subtract one relation from another.

```coffeescript
suggestToFollow = rankedAuthors.difference(followedAuthors)
```

## Working with Records

### Reading / Writing Field Values

Field accessor methods are available on your records for every column defined
on their class.

```coffeescript
blog = Blog.find(11)
console.log "#{blog.title()} by #{blog.user().fullName()}

# just like in jQuery, call field accessors with an argument to assign values
blog.title("New Title")
blog.save() # more on saving later
```

### Observing Record Updates

In addition to observing collections of objects via relations, you can also
observe individual records with `onUpdate`.

```coffeescript
blog.onUpdate (changeset) ->
  if changeset.title
    oldTitle = changeset.title.oldValue
    newTitle = changeset.title.newValue
    console.log "The blog title changed from #{oldValue} to #{newValue}"
```

`onUpdate` returns a subscription object. Call `destroy` on it when you are no
longer interested in updates.

```coffeescript
subscription = blog.onUpdate -> ...

# I don't care about updates any more
subscription.destroy()
```

### Synthetic Columns

### Associations

### CRUD Operations


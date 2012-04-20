# Monarch

Monarch is a relational modeling framework for client-centric web applications.
It's superficially similar to Backbone.js, but it uses the relational algebra as
a declarative, compositional language for querying data and subscribing to
events. Monarch is written in CoffeeScript, but can also be used from
JavaScript.


## Defining Models

Monarch associates model constructors with tables in an in-memory relational
database, in the same way ActiveRecord associates a Ruby class with a table on a
database server.

### In CoffeeScript

To define a record class in CoffeeScript, create a subclass of `Monarch.Record`,
then call the `@extended` class method with a reference to the current class and
define the table's schema by passing a hash to the `@columns` class method.

```coffeescript
class Blog extends Monarch.Record
  @extended(this)

  @columns
    userId: 'integer'
    title: 'string'
    createdAt: 'datetime'
```

### In JavaScript

To define a record class in JavaScript, first create a constructor, then pass it
to the top-level `Monarch` function along with a hash of column definitions. It
will automatically be setup as a subclass of `Monarch.Record`. The `Monarch`
function returns your constructor, so class methods like `hasMany` can be called
immediately in a method-chaining style. More on that later.

```javascript
function() Blog {}

Monarch(Blog, {
  userId: 'integer',
  title: 'string',
  createdAt: 'datetime'
});
```

Unless otherwise noted, examples will be shown in CoffeeScript from here on out.


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


## Querying the Local Repository

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

To retrieve a relation's records, call its `all` method. You can also iterate
over every record in the relation using `each` and `map`. For example:

```coffeescript
# iterate over posts in blog 42
Post.where(blogId: 42).each (post) ->
  console.log(post.title())
```

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
# Note: Composing with the popularAuthors relation defined above
popularAuthorsAndBlogs = popularAuthors.join(Blog, ownerId: 'Blog.id')

# Equivalent SQL:
# select *
# from blogs
#   inner join blogs on owner_id = blogs.id
# where users.privacy = 'public' and users.reputation >= 500
```

If one table references the other by name in its foreign-key, Monarch will infer
the join predicate. For example, if the Post table has a `blogId` column, then
you could write `Blog.join(Post)` without supplying `postId: 'Blog.id'` as a
second argument.

### Projection

### Order By

### Limit and Offset

### Difference

### Union

## Working with Records



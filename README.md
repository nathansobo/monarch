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

You can also call `Monarch.Repository.update` with an array of create, update,
and destroy operations.
This is useful, for example, when you are handling update events delivered via a
web socket.

```coffeescript
Monarch.Repository.update([
  ['create', 'BlogPost', { id: 3, blog_id: 2, title: "I Love Star Wars!" }],
  ['update', 'BlogPost', 2, { title: "I Can't Decide on a Title'" }],
  ['destroy', 'BlogPost', 2]
])
```

### Custom jQuery Ajax Data Types

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

Once you've loaded some data into the repository, you can query it with the
standard relational operators. The result of each operation is called a
*relation*, and can be used as input to another operation. For example, a query
to find all posts of public blogs with more than five comments would be written
as follows:

```coffeescript
Blog.where(public: true).join(Post.where('commentCount >': 5))
```

### Selection (Where)

You can filter the records of any relation by calling `where` on it with a hash
of predicates. You can express standard inequality operations by following a
column name with the operator in the hash key. Predicates, which are expressed
as key-value pairs of the hash are implicitly *anded* together. *Or* operations
aren't finished yet, but will be expressed by the `whereAny` method.

```coffeescript
skilledLadies = User.where(gender: 'female', 'score >=': 500)
```

### Inner Joins

### Projection

### Order By

### Limit and Offset

### Difference

### Union

## Working with Records



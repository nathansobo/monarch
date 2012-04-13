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

Once you've defined some record classes, you load data into their associated
tables in the repository by calling `Monarch.Repository.update` with a hash of
records.

```coffeescript
Monarch.Repository.update(
  blogs:
    1: { user_id: 1, title: "Blog I Never Update", created_at: 1332433460811 },
    2: { user_id: 2, title: "Blog That No One Reads", created_at: 1332433434561 }
  blog_posts:
    1: { blog_id: 1, title: "First Post", body: "More to come!" },
    2: { blog_id: 2, title: "I'm Lonely'", body: "Please read my LiveJournal." },
    3: { blog_id: 2, title: "Comments", body: "No one commented on my last post." }
)
```

As you can see above, the hash can contain records for multiple tables, and is
structured as follows: `table_name -> record_id-> column_name -> field_value`.
Note that the keys are in underscore format rather than camel case. This is in
the process of changin. If a record for a given (table name, id) pair already
exists, it will be updated with the new values. Otherwise a new record will be
created.

You can also call `Monarch.Repository.update` with an array of CRUD operations.
This is useful, for example, when you are handling update events delivered via a
web socket.

```coffeescript
Monarch.Repository.update([
  ['create', 'blog_posts', { id: 3, blog_id: 2, title: "I Love Star Wars!" }],
  ['update', 'blog_posts', 2, { title: "I Can't Decide on a Title'" }],
  ['destroy', 'blog_posts', 2]
])
```

## Working with Records



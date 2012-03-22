# Monarch

Monarch is a relational modeling framework for client-heavy web applications.
It's similar to Backbone.js, but based on the powerful abstractions of
relational algebra, offering a declarative and compositional language for
querying data and subscribing to events.


## Defining Models

Monarch associates model constructors with tables in an in-memory relational
database, similar to how ActiveRecord associates a Ruby class with a table in
MySQL.

```javascript
Blog = Monarch('Blog', {
  userId: 'integer',
  title: 'string',
  createdAt: 'datetime'
});

BlogPost = Monarch('BlogPost', {
  blogId: 'integer',
  title: 'string',
  body: 'string',
});
```

To define a constructor/table pair, call the global `Monarch` function
with the constructor's name (for debugging purposes) and a hash of column
declarations. The columns hash contains each column's name as a key and each
column's type as a value. Every table is given an integer-typed `id` column as
its primary key by default. This will return a constructor function that you can
assign to a global variable.

## Loading Data

Once you've defined some tables, you can load data into the client-side database
by calling `Monarch.Repository.update` with a hash of records.

```javascript
Monarch.Repository.update({
  blogs: {
    1: { user_id: 1, title: "Blog I Never Update", created_at: 1332433460811 },
    2: { user_id: 2, title: "Blog That No One Reads", created_at: 1332433434561 }
  }
  blog_posts: {
    1: { blog_id: 1, title: "First Post", body: "More to come!" },
    2: { blog_id: 2, title: "I'm Lonely'", body: "Please read my LiveJournal." },
    3: { blog_id: 2, title: "Comments", body: "No one commented on my last post." }
  }
});
```

As you can see above, the hash can contain records for multiple tables, and is
structured as follows: `table_name -> record_id-> column_name -> field_value.`
Note that the keys are in underscore format rather than camel case. If a record
for a given (table name, id) pair already exists, it will be updated with the
new values. Otherwise a new record will be created.

You can also call `Monarch.Repository.update` with an array of CRUD operations.
This is useful, for example, when you are handling update events delivered via a
web socket.

```javascript
Monarch.Repository.update([
  ['create', 'blog_posts', { id: 3, blog_id: 2, title: "I Love Star Wars!" }],
  ['update', 'blog_posts', 2, { title: "I Can't Decide on a Title'" }],
  ['destroy', 'blog_posts', 2]
])
```

## Working with Records



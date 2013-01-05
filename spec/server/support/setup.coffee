pg = require 'pg'
_ = require 'underscore'
{ series } = require 'async'
testConfig = require './database'
adminConfig = _.extend({}, testConfig, database: 'postgres')
testDatabase = testConfig.database

series [

  (f) ->
    pg.connect adminConfig, (err, client) ->
      return f(err) if err
      series [
        (f) -> client.query(
          "DROP DATABASE IF EXISTS #{testDatabase};", f)
        (f) -> client.query(
          "CREATE DATABASE #{testDatabase};", f)
      ], f

  (f) ->
    pg.connect testConfig, (err, client) ->
      return f(err) if err
      client.query """
        DROP TABLE IF EXISTS "blogs";
        DROP TABLE IF EXISTS "blog_posts";
        DROP TABLE IF EXISTS "comments";

        CREATE TABLE "blogs" (
          id integer,
          public boolean,
          title varchar,
          author_id integer);

        CREATE TABLE "blog_posts" (
          id integer,
          public boolean,
          title varchar,
          blog_id integer);

        CREATE TABLE "comments" (
          id integer,
          body varchar,
          author_id integer,
          blog_post_id integer);
      """, f

], (e) ->
  message = if e then ("Error:" + e) else "Success."
  console.log message
  pg.end()

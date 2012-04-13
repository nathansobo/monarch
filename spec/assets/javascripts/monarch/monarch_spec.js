describe("Monarch", function() {
  it("takes a constructor and sets it up as a record", function() {
    function Blog() { }
    result = Monarch(Blog, {
      title: 'string',
      userId: 'integer'
    });

    expect(result).toBe(Blog);
    expect(Blog.table.name).toBe('Blog')
    expect(Blog.getColumn('title').type).toBe('string')
    expect(Blog.getColumn('userId').type).toBe('integer')
  });
});

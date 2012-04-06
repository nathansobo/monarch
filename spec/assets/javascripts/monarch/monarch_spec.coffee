describe "Monarch", ->
  describe "calling the top level Monarch constant as a function", ->
    it "returns a record class by the given name with the given column definitions", ->
      klass = Monarch("Blog",
        title: 'string',
        userId: 'integer'
      )

      expect(klass.table.name).toBe 'Blog'
      expect(klass.getColumn('title').type).toBe('string')
      expect(klass.getColumn('userId').type).toBe('integer')

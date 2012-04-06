describe "Monarch.Util.Signal", ->
  describe "multiple signals combined", ->
    it "applies the transformer to all the input sources", ->
      class User extends Monarch.Record
        @inherited(this)
        @columns
          firstName: 'string',
          middleName: 'string',
          lastName: 'string'

        @syntheticColumn 'fullName', ->
          @signal('firstName', 'middleName', 'lastName')

        @syntheticColumn 'lastFirst', ->
          @signal 'firstName', 'middleName', 'lastName', (first, middle, last) ->
            last + ", " + first + ", " + middle

      user = User.created(id: 1, firstName: "John", lastName: "Smith", middleName: "Roy")
      changeCallback = jasmine.createSpy('changeCallback')

      user.signal('fullName').onChange(changeCallback)

      expect(user.fullName()).toEqual("John Roy Smith")

      user.updated(firstName: "Bob")

      expect(changeCallback).toHaveBeenCalledWith("Bob Roy Smith", "John Roy Smith")

      user.updated(lastName: "Dole")

      expect(changeCallback).toHaveBeenCalledWith("Bob Roy Dole", "Bob Roy Smith")

      user.updated(middleName: "Doink")

      expect(changeCallback).toHaveBeenCalledWith("Bob Doink Dole", "Bob Roy Dole")

      expect(user.lastFirst()).toBe("Dole, Bob, Doink")

{ Monarch } = require "../../server_helper"

describe "Visitors.Base", ->
  class Grandparent
  class Parent extends Grandparent
  class Child1 extends Parent
  class Child2 extends Parent

  class OtherParent
  class OtherChild

  class SomeVisitor extends Monarch.Visitors.Base
    visitGrandparent: (obj) ->
      'visited grandparent'

    visitChild1: (obj) ->
      'visited child'

  visitor = null

  beforeEach ->
    visitor = new SomeVisitor

  describe "#visit(visitee)", ->
    it "calls the visit method for the visitee's class", ->
      expect(visitor.visit(new Child1)).toBe('visited child')

    it "finds the visitee's nearest ancestor class for which a visit method is implemented", ->
      expect(visitor.visit(new Child2)).toBe('visited grandparent')

    it "throws an exception if no visit method is found", ->
      expect(->
        visitor.visit(new OtherChild)
      ).toThrow(new Error("Dont' know how to visit #{new OtherChild}"))

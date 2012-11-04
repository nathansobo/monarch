{ Monarch } = require "../spec_helper"

describe "Util.Visitors", ->
  class UnqualifiedClass
  class QualifiedClass
    @qualifiedName = "SomeModule_QualifiedClass"
  class OtherClass

  SomeVisitor =
    visit: Monarch.Util.Visitor.visit,

    visit_UnqualifiedClass: (obj) ->
      'visited unqualified class'

    visit_SomeModule_QualifiedClass: (obj) ->
      'visited qualified class'

  describe "#visit(visitee)", ->
    it "calls the visit method for the visitee's class", ->
      expect(SomeVisitor.visit(new UnqualifiedClass)).toBe('visited unqualified class')

    it "uses the class's 'qualified name' if it has one", ->
      expect(SomeVisitor.visit(new QualifiedClass)).toBe('visited qualified class')

    it "throws an exception if no visit method is found", ->
      expect(->
        SomeVisitor.visit(new OtherClass)
      ).toThrow(new Error("Cannot visit OtherClass"))

    it "throws an exception if no object is passed", ->
      expect(-> SomeVisitor.visit(undefined)).toThrow(new Error("Cannot visit undefined"))
      expect(-> SomeVisitor.visit(null)).toThrow(new Error("Cannot visit null"))
